import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'refund_job_provider.g.dart';

sealed class RefundResult {
  const RefundResult();
}

final class RefundSuccess extends RefundResult {
  final int amount;
  const RefundSuccess(this.amount);
}

final class RefundFailure extends RefundResult {
  /// 사용자에게 보여줄 안내 문구의 로케일 키. View에서 `.tr()`로 다국어 처리한다.
  /// (PG 원문 메시지는 사용자에게 노출하지 않고 Slack 로그로만 남긴다.)
  final String reasonKey;
  const RefundFailure(this.reasonKey);
}

@riverpod
class RefundJobNotifier extends _$RefundJobNotifier {
  @override
  AsyncValue<RefundResult?> build() => const AsyncValue.data(null);

  Future<void> process(MachineJobPollingResponse response) async {
    if (state.isLoading) return;
    // 처리 시작 후에는 홈 화면이 dispose돼도 환불(취소→주문갱신→job 종결)이 끝까지 완료되도록 살려둔다.
    final link = ref.keepAlive();
    state = const AsyncValue.loading();
    try {
      final result = await _processRefund(response);
      state = AsyncValue.data(result);
    } catch (e) {
      final printJobId = response.printJobId;
      SlackLogService().sendErrorLogToSlack('환불 job($printJobId) 예상치 못한 오류: $e');
      if (printJobId != null) {
        await _failJob(printJobId, '환불 처리 중 예상치 못한 오류: $e');
      }
      state = AsyncValue.data(const RefundFailure(LocaleKeys.alert_txt_refund_failed));
    } finally {
      link.close();
    }
  }

  Future<RefundResult?> _processRefund(MachineJobPollingResponse response) async {
    final refundInfo = response.refundInfo;
    final printJobId = response.printJobId;
    final kioskOrderId = refundInfo?.kioskOrderId;

    if (refundInfo == null || printJobId == null || kioskOrderId == null) {
      final reason = '환불 job 필수 필드 누락 '
          '(printJobId=$printJobId, kioskOrderId=$kioskOrderId, refundInfo=${refundInfo == null ? 'null' : 'ok'})';
      SlackLogService().sendErrorLogToSlack(reason);
      if (printJobId != null) {
        await _failJob(printJobId, reason);
      }
      return null;
    }

    // Phase 0: 단말기 응답 확인 — 응답이 없으면(throw) 환불 진행 불가.
    // C0(디바이스 조회)는 정상 시 RES가 0000이 아니라 1001로 와서 코드값으로 판정하지 않고,
    // 응답 수신 여부로만 판단한다(기존 setup_main_screen._checkPaymentDevice와 동일 컨벤션).
    try {
      await ref.read(paymentRepositoryProvider).check();
    } catch (e) {
      await _failJob(printJobId, '단말기 점검 실패(응답 없음): $e');
      return const RefundFailure(LocaleKeys.alert_txt_refund_terminal_error);
    }

    // Phase 1: 결제사 취소 — 실패 시 failMachineJob 가능
    final PaymentResponse paymentResponse;
    try {
      paymentResponse = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: refundInfo.amount,
            originalApprovalNo: refundInfo.originalApprovalNo,
            originalApprovalDate: refundInfo.originalApprovalDate,
          );
    } catch (e) {
      await _failJob(printJobId, '환불 실패: $e');
      return const RefundFailure(LocaleKeys.alert_txt_refund_failed);
    }

    // Phase 2: cancel 완료 이후 — 성공 판정은 프로젝트 표준(orderState)에 맞춘다.
    // (isSuccess=true면 실제 환불됨 → succeed, 금지: fail)
    final isSuccess = paymentResponse.orderState == OrderStatus.refunded;
    final kioskInfo = ref.read(kioskInfoServiceProvider);

    if (kioskInfo == null) {
      SlackLogService().sendErrorLogToSlack(
        '환불 job($printJobId) kioskInfo null — 수동 정산 필요 (isSuccess=$isSuccess)',
      );
      if (isSuccess) {
        await _succeedJob(printJobId);
      } else {
        await _failJob(printJobId, 'kioskInfo null');
      }
      return null;
    }

    final int machineId;
    final UpdateOrderRequest statusRequest;
    try {
      machineId = kioskInfo.kioskMachineId;
      statusRequest = UpdateOrderRequest(
        kioskEventId: refundInfo.kioskEventId,
        kioskMachineId: kioskInfo.kioskMachineId,
        photoAuthNumber: refundInfo.photoAuthNumber,
        status: isSuccess ? OrderStatus.refunded : OrderStatus.refunded_failed,
        amount: refundInfo.amount,
        purchaseAuthNumber: refundInfo.originalApprovalNo,
        authSeqNumber: refundInfo.originalApprovalNo,
        approvalNumber: refundInfo.originalApprovalNo,
        description: isSuccess
            ? null
            : (paymentResponse.msg?.isNotEmpty == true ? paymentResponse.msg : paymentResponse.message1),
        detail: paymentResponse.KSNET,
      );
    } catch (e) {
      SlackLogService().sendErrorLogToSlack(
        '환불 job($printJobId) 상태 요청 구성 실패 — 수동 정산 필요: $e',
      );
      if (isSuccess) {
        await _succeedJob(printJobId);
      } else {
        await _failJob(printJobId, '상태 요청 구성 실패: $e');
      }
      return isSuccess ? RefundSuccess(refundInfo.amount) : null;
    }

    // 주문 상태 갱신 (3회 재시도, 점진적 백오프). 성공 여부를 추적한다.
    var orderUpdated = false;
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await ref.read(kioskRepositoryProvider).updateOrderStatus(kioskOrderId, statusRequest);
        orderUpdated = true;
        break;
      } catch (e) {
        if (attempt >= 3) {
          SlackLogService().sendErrorLogToSlack(
            '[MachineId: $machineId] 환불 job($printJobId) updateOrderStatus 3회 실패: $e',
          );
        } else {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    if (isSuccess) {
      await _succeedJob(printJobId);
      // 성공: 브로드캐스트 알림 (동작로직: web 어드민 환불)
      SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefund.key,
          paymentDescription:
              "동작로직: web 어드민 환불\n- 인증번호: ${refundInfo.photoAuthNumber}\n- 승인번호: ${refundInfo.originalApprovalNo}\n- 금액: ${refundInfo.amount}원");
      if (!orderUpdated) {
        // 카드 취소(환불)는 됐지만 주문 상태 갱신 실패 → 데이터 불일치, 사람이 직접 정산 필요
        SlackLogService().sendErrorLogToSlack(
          '[MachineId: $machineId] ⚠️ polling 환불 성공했으나 주문 상태 갱신 실패 — 수동 정산 필요 '
          '| job=$printJobId | orderId=$kioskOrderId | ${refundInfo.amount}원',
        );
      }
      return RefundSuccess(refundInfo.amount);
    } else {
      // 실패: PG 원문 대신 응답코드 기반 상세 사유로 통일
      final reason = refundReasonFor(paymentResponse);
      await _failJob(printJobId, reason);
      SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
          paymentDescription:
              "동작로직: web 어드민 환불\n- 사유: $reason\n- 인증번호: ${refundInfo.photoAuthNumber}\n- 승인번호: ${refundInfo.originalApprovalNo}");
      return const RefundFailure(LocaleKeys.alert_txt_refund_failed);
    }
  }

  /// job을 실패로 종결. 내부 호출 실패 시에도 반드시 Slack에 남긴다 (무음 방지).
  Future<void> _failJob(int printJobId, String reason) async {
    try {
      await ref.read(kioskRepositoryProvider).failMachineJob(
            printJobId: printJobId,
            failureReason: reason,
          );
    } catch (e) {
      SlackLogService().sendErrorLogToSlack('환불 job($printJobId) failMachineJob 실패: $e');
    }
  }

  /// job을 성공으로 종결. 내부 호출 실패 시에도 반드시 Slack에 남긴다.
  Future<void> _succeedJob(int printJobId) async {
    try {
      await ref.read(kioskRepositoryProvider).succeedMachineJob(printJobId);
    } catch (e) {
      SlackLogService().sendErrorLogToSlack('환불 job($printJobId) succeedMachineJob 실패: $e');
    }
  }
}

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_failed_type.dart';
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
  final String reason;
  const RefundFailure(this.reason);
}

@riverpod
class RefundJobNotifier extends _$RefundJobNotifier {
  @override
  AsyncValue<RefundResult?> build() => const AsyncValue.data(null);

  Future<void> process(MachineJobPollingResponse response) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    try {
      final result = await _processRefund(response);
      state = AsyncValue.data(result);
    } catch (e) {
      final printJobId = response.printJobId;
      SlackLogService().sendErrorLogToSlack('환불 job($printJobId) 예상치 못한 오류: $e');
      if (printJobId != null) {
        try {
          await ref.read(kioskRepositoryProvider).failMachineJob(
                printJobId: printJobId,
                failureReason: '환불 처리 중 예상치 못한 오류: $e',
              );
        } catch (e2) {
          SlackLogService().sendErrorLogToSlack('환불 job($printJobId) failMachineJob 실패: $e2');
        }
      }
      state = AsyncValue.data(RefundFailure(e is PaymentFailedException ? e.message : '환불을 완료하지 못했어요.'));
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
        try {
          await ref.read(kioskRepositoryProvider).failMachineJob(
                printJobId: printJobId,
                failureReason: reason,
              );
        } catch (e) {
          SlackLogService().sendErrorLogToSlack('환불 job($printJobId) failMachineJob 실패: $e');
        }
      }
      return null;
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
      try {
        await ref.read(kioskRepositoryProvider).failMachineJob(
              printJobId: printJobId,
              failureReason: '환불 실패: $e',
            );
      } catch (e2) {
        SlackLogService().sendErrorLogToSlack('환불 job($printJobId) failMachineJob 실패: $e2');
      }
      return RefundFailure(e is PaymentFailedException ? e.message : '환불을 완료하지 못했어요.');
    }

    // Phase 2: cancel 완료 이후 — isSuccess=true면 failMachineJob 금지
    final isSuccess = paymentResponse.isSuccess || paymentResponse.isAlreadyCanceled;
    final kioskInfo = ref.read(kioskInfoServiceProvider);

    if (kioskInfo == null) {
      SlackLogService().sendErrorLogToSlack(
        '환불 job($printJobId) kioskInfo null — 수동 정산 필요 (isSuccess=$isSuccess)',
      );
      try {
        if (isSuccess) {
          await ref.read(kioskRepositoryProvider).succeedMachineJob(printJobId);
        } else {
          await ref.read(kioskRepositoryProvider).failMachineJob(
                printJobId: printJobId,
                failureReason: 'kioskInfo null',
              );
        }
      } catch (e) {
        SlackLogService().sendErrorLogToSlack('환불 job($printJobId) job 종결 실패: $e');
      }
      return null;
    }

    final int machineId;
    final UpdateMachineJobOrderRequest statusRequest;
    try {
      machineId = kioskInfo.kioskMachineId;
      statusRequest = UpdateMachineJobOrderRequest(
        kioskEventId: refundInfo.kioskEventId,
        kioskMachineId: kioskInfo.kioskMachineId,
        status: isSuccess ? OrderStatus.refunded : OrderStatus.refunded_failed,
        amount: refundInfo.amount,
        authSeqNumber: isSuccess ? (paymentResponse.approvalNo ?? '-') : '-',
        approvalNumber: isSuccess ? (paymentResponse.approvalNo ?? '-') : '-',
        description: isSuccess
            ? null
            : (paymentResponse.msg?.isNotEmpty == true ? paymentResponse.msg : paymentResponse.message1),
        detail: paymentResponse.KSNET,
      );
    } catch (e) {
      SlackLogService().sendErrorLogToSlack(
        '환불 job($printJobId) 상태 요청 구성 실패 — 수동 정산 필요: $e',
      );
      try {
        if (isSuccess) {
          await ref.read(kioskRepositoryProvider).succeedMachineJob(printJobId);
        } else {
          await ref.read(kioskRepositoryProvider).failMachineJob(
                printJobId: printJobId,
                failureReason: '상태 요청 구성 실패: $e',
              );
        }
      } catch (e2) {
        SlackLogService().sendErrorLogToSlack('환불 job($printJobId) job 종결 실패: $e2');
      }
      return isSuccess ? RefundSuccess(refundInfo.amount) : null;
    }

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await ref.read(kioskRepositoryProvider).updateMachineJobOrder(kioskOrderId, statusRequest);
        break;
      } catch (e) {
        if (attempt >= 3) {
          SlackLogService().sendErrorLogToSlack(
            '[MachineId: $machineId] 환불 job($printJobId) updateMachineJobOrder 3회 실패 — 수동 정산 필요: $e',
          );
        }
      }
    }

    if (isSuccess) {
      try {
        await ref.read(kioskRepositoryProvider).succeedMachineJob(printJobId);
      } catch (e) {
        SlackLogService().sendErrorLogToSlack('환불 job($printJobId) succeedMachineJob 실패: $e');
      }
      SlackLogService().sendLogToSlack(
          '[MachineId: $machineId] polling 환불 성공 | job=$printJobId | ${refundInfo.amount}원');
      return RefundSuccess(refundInfo.amount);
    } else {
      final failReason =
          (paymentResponse.msg?.isNotEmpty == true ? paymentResponse.msg : paymentResponse.message1) ?? '환불 실패';
      try {
        await ref.read(kioskRepositoryProvider).failMachineJob(
              printJobId: printJobId,
              failureReason: failReason,
            );
      } catch (e) {
        SlackLogService().sendErrorLogToSlack('환불 job($printJobId) failMachineJob 실패: $e');
      }
      SlackLogService().sendErrorLogToSlack(
        '[MachineId: $machineId] polling 환불 실패 | job=$printJobId | $failReason',
      );
      return RefundFailure('환불을 완료하지 못했어요.');
    }
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_snaptag_kiosk/domain/entities/invoice.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_order_process_provider.g.dart';

@Riverpod(keepAlive: true)
class UserOrderProcess extends _$UserOrderProcess {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// 결제 프로세스 시작
  Future<void> startPayment() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // 1. 사전 검증
      _validatePaymentRequirements();

      // 2. 결제 진행
      await _processPayment();
    });
  }

  /// 환불 프로세스 시작
  Future<void> startRefund() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final approvalInfo = ref.read(approvalInfoProvider);
      if (approvalInfo == null) {
        throw Exception('No payment approval info available');
      }

      await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: ref.read(storageServiceProvider).settings.photoCardPrice,
            originalApprovalNo: approvalInfo.approvalNo ?? '',
            originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
          );

      await _updateOrder(OrderStatus.refunded);
    });

    if (state.hasError) {
      await _updateOrder(OrderStatus.refunded_failed);
    }
  }

  Future<void> _processPayment() async {
    try {
      // 1. 주문 생성
      PostOrderResponse postOrderResponse = await _createOrder();
      ref.read(createOrderInfoProvider.notifier).update(postOrderResponse);

      // 2. 결제 승인
      try {
        PaymentResponse paymentResponse =
            await _approvePayment(ref.read(storageServiceProvider).settings.photoCardPrice);
        ref.read(approvalInfoProvider.notifier).update(paymentResponse);
      } catch (e) {
        await _updateOrder(OrderStatus.failed);
        rethrow;
      }

      // 3. 주문 상태 업데이트
      final response = await _updateOrder(OrderStatus.completed);

      // OrderStatus.completed 상태일 때만 프린트 정보 업데이트
      if (response.status == OrderStatus.completed) {
        ref.read(backPhotoForPrintInfoProvider.notifier).update(response.backPhotoForPrint);
      }
    } catch (e) {
      throw Exception('결제 생성 실패');
    }
  }

  Future<PaymentResponse> _approvePayment(int total) async {
    try {
      final Invoice invoice = Invoice.calculate(total);
      final response = await ref.read(paymentRepositoryProvider).approve(
            totalAmount: invoice.total,
          );

      return response;
    } catch (e) {
      throw Exception('van 결제 : approval 실패');
    }
  }

  Future<PostOrderResponse> _createOrder() async {
    final settings = ref.watch(storageServiceProvider).settings;
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;

    final request = PostOrderRequest(
      kioskEventId: settings.kioskEventId,
      kioskMachineId: settings.kioskMachineId,
      photoAuthNumber: backPhoto?.photoAuthNumber ?? '',
      amount: settings.photoCardPrice,
      paymentType: PaymentType.card,
    );

    return await ref.read(kioskRepositoryProvider).createOrder(request);
  }

  Future<PatchOrderResponse> _updateOrder(OrderStatus status) async {
    try {
      final settings = ref.watch(storageServiceProvider).settings;
      final backPhoto = ref.watch(verifyPhotoCardProvider).value;
      final approval = ref.watch(approvalInfoProvider);

      final request = PatchOrderRequest(
        kioskEventId: settings.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        photoAuthNumber: backPhoto?.photoAuthNumber ?? '',
        amount: settings.photoCardPrice,
        status: status,
        approvalNumber: approval?.approvalNo ?? '',
        purchaseAuthNumber: approval?.approvalNo ?? '',
        uniqueNumber: approval?.approvalNo ?? '',
        authSeqNumber: approval?.tradeUniqueNo ?? '',
        tradeNumber: approval?.tradeUniqueNo ?? '',
        detail: approval?.toJson().toString() ?? '',
      );
      final orderId = ref.watch(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }
      return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    } catch (e) {
      throw Exception('주문 업데이트 실패');
    }
  }

  void _validatePaymentRequirements() {
    final settings = ref.watch(storageServiceProvider).settings;
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;

    if (settings.kioskEventId == 0) {
      throw Exception(KioskErrorType.missingEventId);
    }
    if (settings.photoCardPrice <= 0) {
      throw Exception('Invalid photo card price');
    }
    if (backPhoto == null) {
      throw Exception('No back photo available');
    }
  }
}

@riverpod
class SetUpRefundProcess extends _$SetUpRefundProcess {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> startRefund(OrderEntity order) async {
    state = const AsyncLoading();
    if (order.paymentAuthNumber == null) {
      throw Exception('No payment auth number available');
    }
    if (order.completedAt == null) {
      throw Exception('No completed date available');
    }
    await AsyncValue.guard(() async {
      final Invoice invoice = Invoice.calculate(order.amount.toInt());
      PaymentResponse response = await ref.read(paymentRepositoryProvider).cancel(
          totalAmount: invoice.total,
          originalApprovalNo: order.paymentAuthNumber ?? '',
          originalApprovalDate: DateFormat('yyMMdd').format(order.completedAt!));

      await updateOrder(OrderStatus.refunded, order, response);
    });

    if (state.hasError) {
      /**
       await updateOrder(
        OrderStatus.refunded_failed,
        order,
      );
       */
    }
  }

  Future<void> updateOrder(OrderStatus status, OrderEntity order, PaymentResponse payment) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final kioskEventId = ref.watch(storageServiceProvider).settings.kioskEventId;
      final request = PatchOrderRequest(
        kioskEventId: kioskEventId,
        kioskMachineId: order.kioskMachineId,
        photoAuthNumber: order.photoAuthNumber,
        amount: order.amount.toInt(),
        status: status,
        approvalNumber: payment.approvalNo ?? '',
        purchaseAuthNumber: payment.approvalNo ?? '',
        uniqueNumber: payment.approvalNo ?? '',
        authSeqNumber: payment.tradeUniqueNo ?? '',
        tradeNumber: payment.tradeUniqueNo ?? '',
        detail: payment.toJson().toString(),
      );
      final orderId = ref.watch(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }
      await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    });
  }
}

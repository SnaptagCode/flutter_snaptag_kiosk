import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

/// 결제와 환불 로직을 담당하는 UseCase
class PaymentUseCase {
  final Ref ref;

  PaymentUseCase({
    required this.ref,
  });

  /// 주문 생성 → 결제 승인 → 최종 상태(주문) 업데이트
  ///
  /// - [kioskEventId], [kioskMachineId], [photoAuthNumber], [amount] 등
  ///   필요한 값은 Presentation(혹은 Service)에서 전달받아 사용
  Future<(PaymentResponse, UpdateOrderResponse)> processPayment({
    required int kioskEventId,
    required int kioskMachineId,
    required String photoAuthNumber,
    required int amount,
  }) async {
    // (1) 주문 생성
    final createOrderRequest = CreateOrderRequest(
      kioskEventId: kioskEventId,
      kioskMachineId: kioskMachineId,
      photoAuthNumber: photoAuthNumber,
      amount: amount,
      paymentType: PaymentType.card, // 카드 고정이라면
    );
    final createOrderResponse = await ref.read(kioskRepositoryProvider).createOrderStatus(createOrderRequest);

    // (2) 결제 승인
    final paymentResponse = await ref.read(paymentRepositoryProvider).approve(totalAmount: amount);

    // (3) 주문 상태 업데이트
    final updateOrderRequest = UpdateOrderRequest(
      kioskEventId: kioskEventId,
      kioskMachineId: kioskMachineId,
      photoAuthNumber: photoAuthNumber,
      amount: amount,
      status: paymentResponse.orderState, // 성공/실패 여부
      approvalNumber: paymentResponse.approvalNo ?? '-',
      purchaseAuthNumber: paymentResponse.approvalNo ?? '-',
      authSeqNumber: paymentResponse.approvalNo ?? '-',
      detail: paymentResponse.KSNET, // 결제 상세
    );
    final updateOrderResponse = await ref.read(kioskRepositoryProvider).updateOrderStatus(
          createOrderResponse.orderId,
          updateOrderRequest,
        );

    // (4) 만약 결제가 성공이라면, updateOrderResponse를 통해
    //     backPhotoForPrint 등 추가 상태를 반환할 수 있음
    //     -> Presentation에서 사용

    return (paymentResponse, updateOrderResponse);
  }

  /// 환불 UseCase
  ///
  /// - [kioskMachineId], [order], [amount] 등
  ///   필요한 값은 호출부에서 전달
  Future<PaymentResponse> refundPayment({
    required int kioskEventId,
    required int kioskMachineId,
    required int amount,
    required String originalApprovalNo,
    required String originalApprovalDate,
    required int orderId,
    // 필요한 경우 OrderEntity 등 전체 객체를 받을 수도 있음
  }) async {
    // (1) 환불 API 호출
    final response = await ref.read(paymentRepositoryProvider).cancel(
          totalAmount: amount,
          originalApprovalNo: originalApprovalNo,
          originalApprovalDate: originalApprovalDate,
        );

    // (2) 주문 업데이트 (refund 성공/실패)
    final updateOrderRequest = UpdateOrderRequest(
      kioskEventId: kioskEventId,
      kioskMachineId: kioskMachineId,
      photoAuthNumber: '-', // 주문에 따라
      amount: amount,
      status: response.orderState, // REFUNDED / REFUNDED_FAILED
      approvalNumber: originalApprovalNo,
      purchaseAuthNumber: originalApprovalNo,
      authSeqNumber: originalApprovalNo,
      detail: response.KSNET,
    );
    await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId, updateOrderRequest);

    return response;
  }
}

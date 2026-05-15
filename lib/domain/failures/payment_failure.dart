/// 결제 실패 예외의 기본 클래스
abstract class PaymentFailedException implements Exception {
  final String message;
  final String? description;

  PaymentFailedException(this.message, {this.description});

  @override
  String toString() => message;
}

/// 승인번호가 없는 결제 실패
class EmptyApprovalNumberException extends PaymentFailedException {
  EmptyApprovalNumberException({String? description}) : super('결제 승인번호가 없습니다.', description: description);
}

/// 알 수 없는 결제 상태로 인한 실패
class UnknownPaymentException extends PaymentFailedException {
  UnknownPaymentException({String? description}) : super('결제 상태를 확인할 수 없습니다.', description: description);
}

/// 결제 처리 중 발생한 일반적인 오류
class PaymentProcessingException extends PaymentFailedException {
  PaymentProcessingException(super.message, {super.description});
}

// 시간 초과 결제 실패
class TimeoutPaymentException extends PaymentFailedException {
  TimeoutPaymentException({String? description}) : super('시간 초과 결제 실패', description: description);
}

// 취소된 결제 실패
class CancelledPaymentException extends PaymentFailedException {
  CancelledPaymentException({String? description}) : super('취소된 결제 실패', description: description);
}

/// 결제 실패 — 주문이 생성된 후 단말기 응답이 실패/취소/타임아웃
/// orderId와 단말기 응답 정보를 담아 notifier가 환불을 시도할 수 있게 함
class PaymentRefundableException implements Exception {
  final String message;
  final int orderId;
  final String approvalNo; // 빈 문자열 가능 — 환불 시도 후 번호 없으면 실패 처리
  final String? tradeTime; // originalApprovalDate 계산용 (yyMMdd 앞 6자리)
  final String? description;

  PaymentRefundableException(
    this.message, {
    required this.orderId,
    required this.approvalNo,
    this.tradeTime,
    this.description,
  });

  @override
  String toString() => message;
}

class OrderCreationException implements Exception {
  final String message;

  OrderCreationException(this.message);

  @override
  String toString() => 'OrderCreationException: $message';
}

class PreconditionFailedException implements Exception {
  final String message;

  PreconditionFailedException(this.message);

  @override
  String toString() => 'PreconditionFailedExption: $message';
}

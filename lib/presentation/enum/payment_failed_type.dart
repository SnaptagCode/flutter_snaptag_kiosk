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

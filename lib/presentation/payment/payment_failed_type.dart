import 'package:flutter_snaptag_kiosk/core/services/payment/refund_result.dart';

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

// 결제 시도 전 실패
class PaymentPreparationException implements Exception {
  final Object cause;

  PaymentPreparationException(this.cause);

  @override
  String toString() => 'PaymentPreparationException: $cause';
}

/// 결제 승인 후 후속 처리 실패로 자동환불을 시도한 결과를 화면에 전달하기 위한 예외.
/// 원래 실패 예외([originalError])와 자동환불 결과([refundResult])를 함께 담는다.
/// (기존 Slack 로그 내용을 보존하기 위해 toString은 원래 오류를 위임한다.)
class PostPaymentRefundException implements Exception {
  final RefundResult refundResult;
  final Object originalError;

  PostPaymentRefundException(this.refundResult, this.originalError);

  @override
  String toString() => originalError.toString();
}

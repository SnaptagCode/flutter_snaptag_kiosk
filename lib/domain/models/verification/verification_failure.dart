import 'package:flutter_snaptag_kiosk/data/models/entities/order_error_entity.dart';

sealed class VerificationFailure {
  const VerificationFailure();
  String get message;
}

final class VerificationFailureExpired extends VerificationFailure {
  const VerificationFailureExpired();
  @override
  String get message => '인증 코드가 만료되었습니다.';
}

final class VerificationFailureRefundRequired extends VerificationFailure {
  final OrderErrorEntity? order;
  const VerificationFailureRefundRequired({this.order});
  @override
  String get message => '환불이 필요한 코드입니다.';
}

final class VerificationFailureInvalidCode extends VerificationFailure {
  const VerificationFailureInvalidCode();
  @override
  String get message => '인증번호를 찾을 수 없습니다.';
}

final class VerificationFailureNetwork extends VerificationFailure {
  const VerificationFailureNetwork();
  @override
  String get message => '네트워크 연결을 확인해주세요.';
}

final class VerificationFailureUnknown extends VerificationFailure {
  final String _message;
  const VerificationFailureUnknown(this._message);
  @override
  String get message => _message;
}

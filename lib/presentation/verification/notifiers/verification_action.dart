sealed class VerificationAction {
  const VerificationAction();
}

final class VerificationActionSubmit extends VerificationAction {
  final String code;
  const VerificationActionSubmit(this.code);
}

final class VerificationActionCancel extends VerificationAction {
  const VerificationActionCancel();
}

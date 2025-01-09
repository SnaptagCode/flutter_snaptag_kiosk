sealed class PaymentException implements Exception {
  const PaymentException();

  const factory PaymentException.needRecheck() = _NeedRecheck;
  const factory PaymentException.inProgress() = _InProgress;
  const factory PaymentException.error(String message) = _Error;
}

class PaymentClientException extends PaymentException {
  PaymentClientException(this.error, this.stackTrace);

  final String error;
  final StackTrace stackTrace;
}

class _NeedRecheck extends PaymentException {
  const _NeedRecheck();

  @override
  String toString() => 'Transaction needs recheck or manual confirmation';
}

class _InProgress extends PaymentException {
  const _InProgress();

  @override
  String toString() => 'Transaction in progress';
}

class _Error extends PaymentException {
  const _Error(this.message);

  final String message;

  @override
  String toString() => message;
}

sealed class PrinterFailure {
  const PrinterFailure();
  String get message;
}

final class PrinterFailureNotConnected extends PrinterFailure {
  const PrinterFailureNotConnected();
  @override
  String get message => '프린터가 연결되지 않았습니다.';
}

final class PrinterFailureOutOfRibbon extends PrinterFailure {
  const PrinterFailureOutOfRibbon();
  @override
  String get message => '리본이 부족합니다.';
}

final class PrinterFailureFeederEmpty extends PrinterFailure {
  const PrinterFailureFeederEmpty();
  @override
  String get message => '카드가 없습니다.';
}

final class PrinterFailureUnknown extends PrinterFailure {
  final String _message;
  const PrinterFailureUnknown(this._message);
  @override
  String get message => _message;
}

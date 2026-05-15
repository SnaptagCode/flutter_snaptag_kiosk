class PrinterException implements Exception {
  final String message;
  final String code;

  const PrinterException({required this.message, required this.code});

  factory PrinterException.fromError(Object e) => PrinterException(
        message: e.toString(),
        code: 'PRINTER_ERROR',
      );

  factory PrinterException.connectionFailed() => const PrinterException(
        message: '프린터 연결에 실패했습니다.',
        code: 'CONNECTION_FAILED',
      );

  factory PrinterException.outOfRibbon() => const PrinterException(
        message: '리본이 부족합니다.',
        code: 'OUT_OF_RIBBON',
      );

  factory PrinterException.feederEmpty() => const PrinterException(
        message: '카드가 없습니다.',
        code: 'FEEDER_EMPTY',
      );

  @override
  String toString() => '[$code] $message';
}

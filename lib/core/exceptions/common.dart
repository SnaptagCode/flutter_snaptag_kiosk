class KioskException implements Exception {
  final String message;
  KioskException(this.message);

  @override
  String toString() => message;
}

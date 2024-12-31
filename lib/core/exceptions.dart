class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}

class KioskException implements Exception {
  final String message;
  KioskException(this.message);

  @override
  String toString() => message;
}

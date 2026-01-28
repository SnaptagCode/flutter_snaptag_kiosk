enum StorageErrorType {
  fileNotFound('파일을 찾을 수 없습니다'),
  directoryNotFound('디렉토리를 찾을 수 없습니다'),
  loadError('파일 로드 중 오류가 발생했습니다'),
  saveError('파일 저장 중 오류가 발생했습니다'),
  downloadError('다운로드 중 오류가 발생했습니다'),
  deleteError('삭제 중 오류가 발생했습니다');

  const StorageErrorType(this.message);
  final String message;
}

class StorageException implements Exception {
  const StorageException(
    this.type, {
    this.path,
    this.originalError,
    this.stackTrace,
  });

  final StorageErrorType type;
  final String? path;
  final Object? originalError;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer(type.message);

    if (path != null) {
      buffer.write('\n경로: $path');
    }

    if (originalError != null) {
      buffer.write('\n상세: $originalError');
    }

    return buffer.toString();
  }
}

abstract class AppException implements Exception {
  final String message;
  final String code;
  const AppException({required this.message, required this.code});
}

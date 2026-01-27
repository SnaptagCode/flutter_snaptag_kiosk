import 'package:dio/dio.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class ServerException extends DioException {
  final ServerError serverError;

  ServerException._(
    this.serverError, {
    required super.requestOptions,
    super.response,
    super.type = DioExceptionType.badResponse,
    super.error,
    super.stackTrace,
  });

  /// Factory constructor to parse the error response and create an instance.
  factory ServerException.fromDioError(DioException dioError) {
    if (dioError.response?.data != null) {
      try {
        final serverError = ServerError.fromJson(dioError.response!.data);
        return ServerException._(
          serverError,
          requestOptions: dioError.requestOptions,
          response: dioError.response,
          type: dioError.type,
          error: dioError.error,
          stackTrace: dioError.stackTrace,
        );
      } catch (e) {
        // If parsing fails, throw original DioException
        throw dioError;
      }
    }
    // If no response data, throw original DioException
    throw dioError;
  }

  @override
  String toString() {
    return '[${serverError.name}] ${serverError.res.message}';
  }
}

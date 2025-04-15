import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioProvider = Provider.family<Dio, String>((ref, baseUrl) {
  final dio = Dio()
    ..options.baseUrl = baseUrl
    ..options.connectTimeout = const Duration(seconds: 30)
    ..options.receiveTimeout = const Duration(seconds: 30);
  dio.interceptors.add(
    DioLogger(
      sendHook: (log) => log.contains('DioError')?
        SlackLogService().sendLogToSlack(log) :
        SlackLogService().sendErrorLogToSlack(log),
      request: false,
    ),
  );
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
    ),
  );
  dio.interceptors.add(QueuedInterceptorsWrapper(
    // Request가 보내기 전에 실행됩니다.
    // 예를 들어, 헤더를 설정하거나 요청을 변환할 수 있습니다.
    onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      return handler.next(options);
    },
    // Response를 받은 후에 실행됩니다.
    // 예를 들어, 상태 코드에 따라 오류 처리를 할 수 있습니다.
    onResponse: (Response response, ResponseInterceptorHandler handler) {
      if (response.statusCode != null && response.statusCode! ~/ 100 != 2) {
        final newError = DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data!['message'], // 표시할 메시지
          error: response.data!['code'], // 사용자 정의 오류 메시지
        );
        // interceptor onError로 전달
        return handler.reject(newError, true);
      }
      return handler.next(response);
    },
    // Error가 발생했을 때 실행됩니다.
    // 예를 들어, 네트워크 오류 처리를 할 수 있습니다.
    onError: (DioException err, handler) async {
      if (err.response?.data != null) {
        try {
          // ServerException으로 wrapping
          return handler.reject(ServerException.fromDioError(err));
        } catch (e) {
          logger.i('ServerError 파싱 실패: $e');
        }
      }
      return handler.next(err); // 원래 에러 전달
    },
  ));

  return dio;
});

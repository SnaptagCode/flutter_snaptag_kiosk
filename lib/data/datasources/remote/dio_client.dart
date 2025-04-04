import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

final dioProvider = Provider.family<Dio, String>((ref, baseUrl) {
  final dio = Dio()
    ..options.baseUrl = baseUrl
    ..options.connectTimeout = const Duration(seconds: 30)
    ..options.receiveTimeout = const Duration(seconds: 30);
  dio.interceptors.add(
    DioLogger(
      sendHook: SlackLogService().sendLogToSlack,
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
      options.extra['startTime'] = DateTime.now();
      final requestSize = _getSizeInBytes(options.data);
      options.extra['requestSize'] = requestSize;
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
        final start = response.requestOptions.extra['startTime'] as DateTime?;
        final duration = DateTime.now().difference(start!);
        debugPrint('요청~응답까지 ${duration.inMilliseconds}ms');
        //final responseSize = _getSizeInBytes(options.data);
        //options.extra['reponseSize'] = responseSize;
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

int _getSizeInBytes(dynamic data) {
  try {
    if (data == null) return 0;
    final jsonStr = data is String ? data : data.toString();
    return utf8.encode(jsonStr).length;
  } catch (_) {
    return 0;
  }
}
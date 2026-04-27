import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Slack 알림을 보낼 API 경로 목록 (startsWith 매칭)
// - 400 이상: log 채널
// - 500 이상: error_log 채널
const _slackMonitoredPaths = [
  '/v1/order',
];

final dioProvider = Provider.family<Dio, String>((ref, baseUrl) {
  final dio = Dio()
    ..options.baseUrl = baseUrl
    ..options.connectTimeout = const Duration(seconds: 30)
    ..options.receiveTimeout = const Duration(seconds: 30);
  dio.interceptors.add(DioLogger(
      sendHook: (log) {
        SlackLogService().sendLogToSlack(log);
      },
      machineIdProvider: () => ref.read(kioskInfoServiceProvider)?.kioskMachineId,
      request: true,
      requestBody: true));
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
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      final statusCode = err.response?.statusCode ?? 0;

      // Slack 알림 API 자체의 에러는 다시 Slack으로 보내지 않음 (무한 루프 방지)
      final isSlackAlertRequest = err.requestOptions.path.contains('slack');

      // DioLogger를 사용해서 예쁘게 가공된 로그 메시지를 받아서 상태 코드별로 분기
      // 실제 handler를 넘기지 않고 더미 핸들러로 로그 포맷팅만 수행
      // (handler를 넘기면 DioLogger 내부에서 handler.next()를 호출해 이중 호출 버그 발생)
      final errorLogger = DioLogger(
        sendHook: (log) {
          if (isSlackAlertRequest) return;
          final path = err.requestOptions.path;
          final isMonitored = _slackMonitoredPaths.any((p) => path.startsWith(p));
          if (!isMonitored) return;
          final lines = log.split('\n');
          if (lines.isNotEmpty) lines[0] = '${lines[0]} ║ MachineId: $machineId';
          final formattedMessage = lines.join('\n');
          if (statusCode >= 400 && statusCode < 500) {
            SlackLogService().sendLogToSlack(formattedMessage);
          } else if (statusCode >= 500) {
            SlackLogService().sendErrorLogToSlack(formattedMessage);
          }
        },
        request: false,
      );

      // DioLogger를 실제로 실행시켜서 sendHook이 호출되도록 함
      // 로깅 전용 핸들러를 별도로 넘겨서 실제 handler가 중복 호출되는 버그 방지
      errorLogger.onError(err, ErrorInterceptorHandler());

      if (err.response?.data != null) {
        try {
          // ServerException으로 wrapping
          return handler.reject(ServerException.fromDioError(err));
        } catch (e) {
          logger.i('SeverError 파싱 실패: $e');
        }
      }
      return handler.next(err); // 원래 에러 전달
    },
  ));

  return dio;
});

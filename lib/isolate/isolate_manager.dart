import 'dart:async';
import 'dart:isolate';

import 'package:flutter_snaptag_kiosk/core/utils/logger_service.dart';

class IsolateManager<T, R> {
  Future<R?> runInIsolate(
    FutureOr<R> Function(T) function,
    T argument,
  ) async {
    try {
      logger.i("✅ IsolateManager start");
      final receivePort = ReceivePort(); // 🎯 메인 Isolate가 응답을 받을 포트 생성
      final isolate = await Isolate.spawn(
        _isolateEntry<T, R>,
        _IsolateMessage(function, argument, receivePort.sendPort),
      );

      final result = await receivePort.first as R?; // 🎯 결과를 대기

      receivePort.close();
      isolate.kill(priority: Isolate.immediate); // 🎯 Isolate 종료

      logger.i("✅ IsolateManager finished result: $result");

      return result;
    } catch (e) {
      logger.e('runInIsolate: $e');
    }
    return null;
  }

  /// Isolate에서 실행될 함수 (독립적인 환경에서 동작)
  static void _isolateEntry<T, R>(_IsolateMessage<T, R> message) async {
    try {
      logger.i("✅ _isolateEntry start");
      final result = await message.function(message.argument);
      message.sendPort.send(result);
    } catch (e) {
      logger.e('_isolateEntry e: $e');
      message.sendPort.send(null);
    }
  }
}

/// ✅ Isolate에서 사용할 메시지 구조
class _IsolateMessage<T, R> {
  final FutureOr<R?> Function(T) function;
  final T argument;
  final SendPort sendPort;

  _IsolateMessage(this.function, this.argument, this.sendPort);
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class AppErrorHandler {
  static late final File _logFile;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // 로그 디렉토리 설정
    final logDir = Directory('logs');
    if (!logDir.existsSync()) {
      logDir.createSync();
    }

    // 날짜별 로그 파일 생성
    final now = DateTime.now();
    final fileName = 'app_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.log';
    _logFile = File(path.join(logDir.path, fileName));
    _initialized = true;

    // Flutter 프레임워크 에러 핸들링
    FlutterError.onError = (details) {
      logError(
        'FLUTTER_ERROR',
        details.exception,
        details.stack,
      );
    };

    // Flutter 에러가 아닌 모든 에러 핸들링
    PlatformDispatcher.instance.onError = (error, stack) {
      logError('PLATFORM_ERROR', error, stack);
      return true;
    };
  }

  static void logError(String type, Object error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    final message = '$timestamp [$type] $error\n${stackTrace ?? ''}\n\n';

    try {
      _logFile.writeAsStringSync(message, mode: FileMode.append);

      // Debug 모드에서는 콘솔에도 출력
      if (kDebugMode) {
        print(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to write to log file: $e');
      }
    }
  }

  static void logInfo(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '$timestamp [INFO] $message\n';

    try {
      _logFile.writeAsStringSync(logMessage, mode: FileMode.append);
      if (kDebugMode) {
        print(logMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to write to log file: $e');
      }
    }
  }

  // 로그 파일 관리 (오래된 로그 삭제)
  static void cleanOldLogs({int maxDays = 30}) {
    try {
      final logDir = Directory('logs');
      if (!logDir.existsSync()) return;

      final now = DateTime.now();
      final files = logDir.listSync();

      for (var entity in files) {
        if (entity is File && entity.path.endsWith('.log')) {
          final fileName = path.basename(entity.path);
          if (fileName.startsWith('app_')) {
            final fileDate = DateTime.parse(fileName.substring(4, 12));
            final difference = now.difference(fileDate).inDays;

            if (difference > maxDays) {
              entity.deleteSync();
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clean old logs: $e');
      }
    }
  }
}

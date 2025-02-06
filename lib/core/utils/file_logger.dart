import 'dart:convert';
import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/utils/logger_service.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

class FileLogger {
  static final FileLogger _instance = FileLogger._internal();
  static late String _logDirectory;

  final Logger _logger = Logger('AppLogger');

  FileLogger._internal() {
    _logger.onRecord.listen((LogRecord rec) {
      _writeLogToFile(rec);
    });
  }

  factory FileLogger.initialize(String logDirectory) {
    _logDirectory = logDirectory;
    return _instance;
  }

  static void log(Level level, String message) {
    logger.d(message);
    _instance._logger.log(level, message);
  }

  static void info(String message) {
    logger.d(message);
    _instance._logger.info(message);
  }

  static void warning(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.d(message, error: error, stackTrace: stackTrace, time: time);
    _instance._logger.warning(message, error, stackTrace);
  }

  static void severe(String message) {
    logger.d(message);
    _instance._logger.severe(message);
  }

  static void fine(String message) {
    logger.d(message);
    _instance._logger.fine(message);
  }

  void _writeLogToFile(LogRecord rec) {
    final now = DateTime.now();
    final directoryPath = path.join(_logDirectory, 'logs', '${now.year}-${now.month}-${now.day}');
    final logFilePath = path.join(directoryPath, 'log.txt');

    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final logFile = File(logFilePath);
    logFile.writeAsStringSync(
      '${rec.time}: ${rec.level.name}: ${rec.message}\n',
      mode: FileMode.append,
      encoding: Encoding.getByName('utf-8')!,
    );
  }
}

import 'dart:io';

import 'package:path/path.dart' as p;

class AppLogService {
  static final AppLogService _instance = AppLogService._internal();
  factory AppLogService() => _instance;
  AppLogService._internal();

  static String get _logPath {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    return p.join(exeDir, 'app.log');
  }

  Future<void> log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    await File(_logPath).writeAsString(
      '[$timestamp] $message\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  Future<void> logError(String message, [Object? error, StackTrace? stack]) async {
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] ERROR: $message');
    if (error != null) buffer.writeln('  error: $error');
    if (stack != null) buffer.writeln('  stack: $stack');
    await File(_logPath).writeAsString(
      buffer.toString(),
      mode: FileMode.append,
      flush: true,
    );
  }
}

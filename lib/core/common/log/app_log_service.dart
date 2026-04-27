import 'dart:io';

import 'package:path/path.dart' as p;

class AppLogService {
  AppLogService._();
  static final AppLogService instance = AppLogService._();

  void info(String message) => _write('INFO ', message, device: false);
  void error(String message) => _write('ERROR', message, device: false);
  void device(String message) => _write('ERROR', message, device: true);

  void _write(String level, String message, {required bool device}) {
    try {
      final now = DateTime.now();
      final date = '${now.year}-${_p(now.month)}-${_p(now.day)}';
      final time = '$date ${_p(now.hour)}:${_p(now.minute)}:${_p(now.second)}';
      final line = '[$time] [$level] $message\n';
      final name = device ? 'device_$date.log' : 'kiosk_$date.log';
      final dir = Directory(p.join(p.dirname(Platform.resolvedExecutable), 'logs'));
      if (!dir.existsSync()) dir.createSync();
      File(p.join(dir.path, name)).writeAsStringSync(line, mode: FileMode.append);
    } catch (_) {}
  }

  String _p(int v) => v.toString().padLeft(2, '0');
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/data/datasources/local/heartbeat_note.dart';
import 'package:path/path.dart' as p;

Future<File?> writeHeartbeat({
  required bool restartOnCrash,
  required String eventId,
  required bool eventRunning,
  required String screen,
  required String printMode,
}) async {
  final home = Platform.environment['USERPROFILE'];
  if (home == null) return null;

  final dir = Directory(p.join(home, 'Snaptag', 'runtime'));
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final file = File(p.join(dir.path, 'heartbeat.json'));
  final tmp = File('${file.path}.tmp');

  final payload = {
    'at': DateTime.now().toIso8601String(),
    'restartOnCrash': restartOnCrash,
    'eventId': eventId,
    'eventRunning': eventRunning,
    'screen': screen,
    'printMode': printMode,
  };

  await tmp.writeAsString(jsonEncode(payload), flush: true);
  await tmp.rename(file.path);

  return file;
}

Future<HeartbeatNote?> readHeartbeat() async {
  try {
    final home = Platform.environment['USERPROFILE'];
    if (home == null) return null;

    final file = File(p.join(home, 'Snaptag', 'runtime', 'heartbeat.json'));
    if (!await file.exists()) return null;

    final decoded = jsonDecode(await file.readAsString());
    return decoded is Map<String, dynamic> ? HeartbeatNote.fromJson(decoded) : null;
  } catch (_) {
    return null;
  }
}

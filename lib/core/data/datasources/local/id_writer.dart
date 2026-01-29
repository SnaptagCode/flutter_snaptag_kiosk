import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

Future<File> writePhotocodeId(String id, String eventId, String singleCardCount, String companyname, String version) async {
  final home = Platform.environment['USERPROFILE']!;
  final dir = Directory(p.join(home, 'Snaptag', 'runtime'));
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final file = File(p.join(dir.path, 'photocode_meta.json'));
  final tmp  = File('${file.path}.tmp');

  final payload = {
    'id': id,
    'eventId' : eventId,
    'singleCardCount' : singleCardCount,
    'companyname' : companyname,
    'version' : version
  };

  await tmp.writeAsString(jsonEncode(payload), flush: true);
  if (await file.exists()) await file.delete();
  await tmp.rename(file.path);

  return file;
}

Future<File> writeSingleCardCount(String singleCardCount) async {
  final home = Platform.environment['USERPROFILE']!;
  final dir = Directory(p.join(home, 'Snaptag', 'runtime'));
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final file = File(p.join(dir.path, 'photocode_meta.json'));
  final tmp  = File('${file.path}.tmp');

  Map<String, dynamic> meta = {};
  if (await file.exists()) {
    try {
      final raw = await file.readAsString();
      final m = jsonDecode(raw);
      if (m is Map<String, dynamic>) {
        meta = m;
      }
    } catch (_) {
      // 무시: 손상/부분쓰기였을 수 있음 → 기본값으로 진행
    }
  }

  meta['id'] = (meta['id'] ?? '').toString();
  meta['eventId'] = (meta['eventId'] ?? '').toString();
  meta['singleCardCount'] = singleCardCount.toString();
  meta['companyname'] = (meta['companyname'] ?? '').toString();
  meta['version'] = (meta['version'] ?? '').toString();

  await tmp.writeAsString(jsonEncode(meta), flush: true);
  if (await file.exists()) await file.delete();
  await tmp.rename(file.path);

  return file;
}
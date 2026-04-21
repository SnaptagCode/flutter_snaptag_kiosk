import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:path/path.dart' as p;

final offlineConfigServiceProvider = Provider<OfflineConfigService>((_) => OfflineConfigService());

class OfflineConfigService {
  static String get _configPath {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    return p.join(exeDir, 'config.json');
  }

  Future<KioskMachineInfo> load() async {
    final file = File(_configPath);
    if (!await file.exists()) {
      throw Exception('config.json을 찾을 수 없습니다: $_configPath');
    }
    final body = await file.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    return KioskMachineInfo.fromJson(json);
  }
}

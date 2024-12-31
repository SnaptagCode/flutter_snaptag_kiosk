import 'dart:io';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

part 'storage_service.g.dart';

class StorageService {
  StorageService._();

  static Future<StorageService> initialize() async {
    final repository = StorageService._();
    await repository._loadSettingsFromFile();
    return repository;
  }

  static const String _fileName = 'kiosk_setting.yaml';
  String get _filePath => path.join(Directory.current.path, _fileName);

  KioskMachineInfo _settings = const KioskMachineInfo();
  KioskMachineInfo get settings => _settings;
  set settings(KioskMachineInfo value) {
    _settings = value;
  }

  // 명시적 새로고침 메서드 추가
  Future<void> reloadSettings() async {
    await _loadSettingsFromFile();
  }

  Future<void> _loadSettingsFromFile() async {
    try {
      final file = File(_filePath);

      if (!await file.exists()) {
        final yamlEditor = YamlEditor('');
        yamlEditor.update([], _settings.toJson());
        await file.writeAsString(yamlEditor.toString());
        logger.d('설정 파일이 없어 새로 생성되었습니다: $_filePath');
        return;
      }

      final yamlString = await file.readAsString();
      final yamlMap = loadYaml(yamlString) as Map;
      final jsonMap = Map<String, dynamic>.from(yamlMap);
      _settings = KioskMachineInfo.fromJson(jsonMap);
    } catch (e, stack) {
      _settings = const KioskMachineInfo();
      throw Exception('설정 파일 로드 중 오류 발생 ($e) 파일 경로: $_filePath\n$stack');
    }
  }

  Future<void> saveSettings(KioskMachineInfo info) async {
    try {
      final file = File(_filePath);
      final yamlEditor = YamlEditor('');
      yamlEditor.update([], info.toJson());
      await file.writeAsString(yamlEditor.toString());
      _settings = info;
      logger.d('설정이 저장되었습니다: $_filePath');
    } catch (e, stack) {
      logger.e('설정 저장 중 오류 발생', error: e, stackTrace: stack);
      throw Exception('설정 저장 중 오류 발생');
    }
  }

  String get filePath => _filePath;
}

@Riverpod(keepAlive: true)
StorageService storageService(StorageServiceRef ref) {
  throw UnimplementedError('Storage service not initialized');
}

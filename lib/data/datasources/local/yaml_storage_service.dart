import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

part 'yaml_storage_service.g.dart';

@Riverpod(keepAlive: true)
YamlStorageService storageService(Ref ref) {
  throw UnimplementedError('Storage service not initialized');
}

class YamlStorageService {
  YamlStorageService._();

  static Future<YamlStorageService> initialize() async {
    final repository = YamlStorageService._();
    await repository._loadSettingsFromFile();
    return repository;
  }

  final _fileSystem = FileSystemService.instance;
  static const String _fileName = 'kiosk_setting.yaml';

  String get filePath => _fileSystem.getFilePath(DirectoryPaths.settings, fileName: _fileName);

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
      await _fileSystem.ensureDirectoryExists(DirectoryPaths.settings);

      final filePath = _fileSystem.getFilePath(DirectoryPaths.settings, fileName: _fileName);
      final file = File(filePath);

      if (!await file.exists()) {
        final yamlEditor = YamlEditor('');
        yamlEditor.update([], _settings.toJson());
        await file.writeAsString(yamlEditor.toString());
        FileLogger.info('설정 파일이 없어 새로 생성되었습니다: $filePath');
        return;
      }

      final yamlString = await file.readAsString();
      final yamlMap = loadYaml(yamlString) as Map;
      final jsonMap = Map<String, dynamic>.from(yamlMap);
      // 이미지 경로 로드

      settings = KioskMachineInfo.fromJson(jsonMap);
    } catch (e, stack) {
      settings = const KioskMachineInfo();

      throw StorageException(
        StorageErrorType.loadError,
        path: filePath,
        originalError: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> saveSettings(KioskMachineInfo info) async {
    try {
      final file = File(filePath);
      final yamlEditor = YamlEditor('');
      final data = {
        ...info.toJson(),
      };
      yamlEditor.update([], data);
      await file.writeAsString(yamlEditor.toString());
      _settings = info;
      FileLogger.info('설정이 저장되었습니다: $filePath');
    } catch (e, stack) {
      FileLogger.warning('설정 저장 중 오류 발생', error: e, stackTrace: stack);
      throw StorageException(
        StorageErrorType.saveError,
        path: filePath,
        originalError: e,
        stackTrace: stack,
      );
    }
  }
}

import 'dart:convert';
import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_snaptag_kiosk/data/models/response/intro_common_data.dart';

class IntroCommonDataHiveCache {
  static const String _boxName = 'intro_common_data';
  static Box? _box;

  /// Hive Box 초기화
  static Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  /// IntroCommonData 리스트를 Hive에 저장
  static Future<void> saveIntroCommonData(List<IntroCommonData> data) async {
    try {
      await init();
      if (_box == null) return;

      // JSON으로 변환하여 저장
      final jsonList = data.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await _box!.put('data', jsonString);
      
      // 개별 코드로 빠른 검색을 위한 인덱스도 저장
      final codeIndex = <String, String>{};
      for (var item in data) {
        codeIndex[item.code] = item.value;
      }
      await _box!.put('code_index', jsonEncode(codeIndex));

      print('getValueByCode saveIntroCommonData jsonString: $jsonString');
    } catch (e) {
      print('Failed to save intro common data to Hive: $e');
    }
  }

  /// Hive에서 IntroCommonData 리스트 불러오기
  static Future<List<IntroCommonData>?> loadIntroCommonData() async {
    try {
      await init();
      if (_box == null) return null;

      final jsonString = _box!.get('data') as String?;
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      print('getValueByCode loadIntroCommonData jsonList: $jsonList');
      return jsonList
          .map((item) => IntroCommonData.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Failed to load intro common data from Hive: $e');
      return null;
    }
  }

  /// 특정 code로 value 찾기 (빠른 검색을 위해 인덱스 사용)
  static Future<String?> getValueByCode(String code) async {
    try {
      await init();
      if (_box == null) return null;

      // 인덱스에서 먼저 확인 (더 빠름)
      final indexJson = _box!.get('code_index') as String?;
      if (indexJson != null) {
        final codeIndex = jsonDecode(indexJson) as Map<String, dynamic>;
        final value = codeIndex[code] as String?;
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }

      // 인덱스에 없으면 전체 데이터에서 검색
      final data = await loadIntroCommonData();
      if (data == null) return null;

      final item = data.firstWhere(
        (item) => item.code == code,
        orElse: () => throw Exception('Not found'),
      );
      print('getValueByCode getValueByCode item: $item');
      
      return item.value;
    } catch (e) {
      return null;
    }
  }

  /// 캐시 삭제
  static Future<void> clearCache() async {
    try {
      await init();
      if (_box == null) return;
      
      await _box!.clear();
    } catch (e) {
      print('Failed to clear intro common data cache: $e');
    }
  }

  /// Box 닫기
  static Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  /// 디버그: 모든 저장된 데이터 조회 및 출력
  static Future<Map<String, dynamic>> getAllDataForDebug() async {
    try {
      await init();
      if (_box == null) return {};

      final data = <String, dynamic>{};
      
      // 전체 데이터
      final jsonString = _box!.get('data') as String?;
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        data['full_data'] = jsonList;
        data['full_data_count'] = jsonList.length;
      }

      // 코드 인덱스
      final indexJson = _box!.get('code_index') as String?;
      if (indexJson != null) {
        final codeIndex = jsonDecode(indexJson) as Map<String, dynamic>;
        data['code_index'] = codeIndex;
        data['code_index_count'] = codeIndex.length;
      }

      // Box 경로 정보
      data['box_name'] = _boxName;
      data['box_path'] = _box!.path;
      data['is_open'] = _box!.isOpen;
      data['keys'] = _box!.keys.toList();

      return data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 디버그: 모든 데이터를 JSON 문자열로 출력
  static Future<String> printAllDataForDebug() async {
    final data = await getAllDataForDebug();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    SlackLogService().sendLogToSlack('=== Hive Cache Debug Info ===');
    SlackLogService().sendLogToSlack(jsonString);
    SlackLogService().sendLogToSlack('=== End of Hive Cache Debug ===');
    return jsonString;
  }

  /// 디버그: Hive 파일 경로 가져오기
  static Future<String?> getHiveFilePath() async {
    try {
      await init();
      if (_box == null) return null;
      return _box!.path;
    } catch (e) {
      return null;
    }
  }

  /// 디버그: 특정 키의 값을 가져오기
  static Future<dynamic> getValueForKey(String key) async {
    try {
      await init();
      if (_box == null) return null;
      return _box!.get(key);
    } catch (e) {
      return null;
    }
  }
}


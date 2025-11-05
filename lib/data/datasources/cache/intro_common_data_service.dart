import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'intro_common_data_service.g.dart';

@Riverpod(keepAlive: true)
class IntroCommonDataService extends _$IntroCommonDataService {
  List<IntroCommonData>? _cachedData;

  @override
  List<IntroCommonData>? build() {
    // build는 동기적으로 실행되므로, 초기화는 나중에 진행
    // Hive 캐시는 getValueByCode에서 확인
    return null;
  }

  /// 초기화 시 Hive 캐시에서 데이터 로드
  Future<void> initialize() async {
    final cachedData = await IntroCommonDataHiveCache.loadIntroCommonData();
    if (cachedData != null && cachedData.isNotEmpty) {
      state = cachedData;
      _cachedData = cachedData;
    }
  }

  /// IntroCommonData를 불러와서 캐시하고 상태 업데이트
  Future<List<IntroCommonData>> fetchAndUpdate() async {
    try {
      // 먼저 Hive 캐시에서 초기화 시도
      if (state == null || state!.isEmpty) {
        await initialize();
      }

      final kioskRepo = ref.read(kioskRepositoryProvider);
      final response = await kioskRepo.getIntroCommonData();
      
      state = response;
      _cachedData = response;
      
      // Hive 캐시에 저장
      await IntroCommonDataHiveCache.saveIntroCommonData(response);

      await IntroCommonDataHiveCache.printAllDataForDebug();
      
      return response;
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// 특정 code로 IntroCommonData 찾기
  IntroCommonData? findByCode(String code) {
    final data = state ?? _cachedData;
    if (data == null) return null;
    
    return data.firstWhereOrNull((item) => item.code == code);
  }

  /// 특정 code의 value 반환 (Hive 캐시 우선)
  Future<String?> getValueByCode(String code) async {

    // 1. 메모리 캐시(state)에서 먼저 확인 (최신 데이터)
    final memoryValue = findByCode(code)?.value;

    if (memoryValue != null && memoryValue.isNotEmpty) {
      print('getValueByCode memoryValue code: $memoryValue');
      return memoryValue;
    }
    
    // 1. Hive 캐시에서 먼저 확인
    final cachedValue = await IntroCommonDataHiveCache.getValueByCode(code);
    if (cachedValue != null && cachedValue.isNotEmpty) {
      print('getValueByCode cachedValue code: $cachedValue');
      return cachedValue;
    }

    
    // 2. 메모리 캐시에서 확인
    return null;
  }

  /// Slack DEV_WEBHOOK_URL 가져오기
  Future<String?> getSlackWebhookUrl() async {
    return await getValueByCode('SLACK_WEBHOOK_URL');
  }

  /// Slack Webhook Error URL 가져오기
  Future<String?> getSlackWebhookErrorUrl() async {
    return await getValueByCode('SLACK_WEBHOOK_ERROR_LOG_URL');
  }

  /// Slack Webhook Ribbon Film Warning URL 가져오기
  Future<String?> getSlackWebhookRibbonFilmWarnUrl() async {
    return await getValueByCode('SLACK_WEBHOOK_RIBBON_FILM_WARN_URL');
  }

  /// Slack Webhook Warning URL 가져오기
  Future<String?> getSlackWebhookWarningUrl() async {
    return await getValueByCode('SLACK_WEBHOOK_WARNING_URL');
  }

  /// Slack Webhook Broadcast URL 가져오기
  Future<String?> getSlackWebhookBroadcastUrl() async {
    return await getValueByCode('DEV_WEBHOOK_URL');
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    await fetchAndUpdate();
  }
}


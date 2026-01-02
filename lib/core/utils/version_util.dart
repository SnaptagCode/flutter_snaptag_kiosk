import 'package:package_info_plus/package_info_plus.dart';

/// 앱 버전을 관리하는 유틸리티 클래스
class VersionUtil {
  static PackageInfo? _packageInfo;
  static String? _cachedVersion;

  /// pubspec.yaml의 버전을 가져옵니다.
  /// 형식: "v3.3.0" (v 접두사 포함)
  static Future<String> getAppVersion() async {
    if (_cachedVersion != null) {
      return _cachedVersion!;
    }

    try {
      _packageInfo ??= await PackageInfo.fromPlatform();
      final version = _packageInfo!.version;
      // 버전에 'v' 접두사가 없으면 추가
      _cachedVersion = version.startsWith('v') ? version : 'v$version';
      return _cachedVersion!;
    } catch (e) {
      // 오류 발생 시 기본값 반환
      return 'v3.3.0';
    }
  }

  /// 버전을 동기적으로 가져옵니다 (캐시된 값 사용)
  /// 주의: getAppVersion()을 먼저 호출해야 합니다.
  static String? getCachedVersion() {
    return _cachedVersion;
  }

  /// 버전 캐시를 초기화합니다 (테스트용)
  static void clearCache() {
    _cachedVersion = null;
    _packageInfo = null;
  }
}


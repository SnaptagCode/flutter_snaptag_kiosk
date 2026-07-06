import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';

/// 앞면 이미지 출력 방식 (JKLI-175)
enum FrontPhotoMode {
  /// 랜덤형: 인쇄 시점에 가중치 랜덤 선택 (기존 동작)
  random,

  /// 선택형: 사용자가 앞면 선택 화면에서 직접 선택
  userSelect,
}

/// 관리자 화면에서 설정하는 앞면 이미지 모드 오버라이드
///
/// null이면 서버(machine/info)의 frontPhotoType을 따르고,
/// 관리자가 설정하면 앱 재시작 전까지 서버 값보다 우선한다.
class FrontPhotoModeOverrideNotifier extends StateNotifier<FrontPhotoMode?> {
  FrontPhotoModeOverrideNotifier() : super(null);

  void set(FrontPhotoMode mode) => state = mode;

  /// 오버라이드 해제 (서버 설정 따름)
  void clear() => state = null;
}

final frontPhotoModeOverrideProvider = StateNotifierProvider<FrontPhotoModeOverrideNotifier, FrontPhotoMode?>(
  (ref) => FrontPhotoModeOverrideNotifier(),
);

/// 실제 적용되는 앞면 선택형 여부 (관리자 오버라이드 > 서버 frontPhotoType)
final isFrontPhotoUserSelectProvider = Provider<bool>((ref) {
  final override = ref.watch(frontPhotoModeOverrideProvider);
  if (override != null) {
    return override == FrontPhotoMode.userSelect;
  }
  return ref.watch(kioskInfoServiceProvider)?.isFrontPhotoUserSelect ?? false;
});

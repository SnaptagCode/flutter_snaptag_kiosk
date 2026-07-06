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

/// 현재 적용 중인 앞면 선택형 여부.
///
/// 서버(machine/info)의 frontPhotoType을 따르며, 관리자가 모드를 변경하면
/// API 호출로 머신정보 state가 갱신되어 이 값도 함께 바뀐다.
final isFrontPhotoUserSelectProvider = Provider<bool>((ref) {
  return ref.watch(kioskInfoServiceProvider)?.isFrontPhotoUserSelect ?? false;
});

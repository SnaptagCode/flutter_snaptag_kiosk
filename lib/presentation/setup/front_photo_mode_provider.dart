import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';

/// 앞면 이미지 출력 방식 (JKLI-175)
enum FrontPhotoMode {
  /// 랜덤형: 인쇄 시점에 가중치 랜덤 선택 (기존 동작)
  random,

  /// 선택형: 사용자가 앞면 선택 화면에서 직접 선택
  userSelect,
}

/// 현재 적용 중인 앞면 선택형 여부.
///
/// 설정된 frontPhotoType이 USER_SELECT이고 인쇄 모드가 양면(double)일 때만 true.
/// 단면(single)은 앞면을 인쇄하지 않으므로 앞면 선택이 무의미해 항상 랜덤형처럼 동작한다.
final isFrontPhotoUserSelectProvider = Provider<bool>((ref) {
  final configured = ref.watch(kioskInfoServiceProvider)?.isFrontPhotoUserSelect ?? false;
  final isDoubleSided = ref.watch(pagePrintProvider) == PagePrintType.double;
  return configured && isDoubleSided;
});

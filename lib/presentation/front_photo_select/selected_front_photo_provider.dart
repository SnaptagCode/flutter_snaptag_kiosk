import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

/// 사용자가 직접 고른 앞면 이미지 (선택형 이벤트 전용)
///
/// null이면 기존대로 인쇄 시점에 랜덤 선택된다.
class SelectedFrontPhotoNotifier extends StateNotifier<NominatedPhoto?> {
  SelectedFrontPhotoNotifier() : super(null);

  /// 앞면 이미지 선택
  void select(NominatedPhoto photo) => state = photo;

  /// 선택 초기화
  void reset() => state = null;
}

final selectedFrontPhotoProvider = StateNotifierProvider<SelectedFrontPhotoNotifier, NominatedPhoto?>(
  (ref) => SelectedFrontPhotoNotifier(),
);

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'triple_tap_state.g.dart';

@riverpod
class TripleTapState extends _$TripleTapState {
  @override
  List<DateTime> build() {
    // 초기 상태로 빈 리스트 반환
    return [];
  }

  void registerTap(void Function() action) {
    final now = DateTime.now();

    // 2초 이상 지난 탭은 제거
    state = state.where((tapTime) => now.difference(tapTime) <= const Duration(seconds: 1)).toList();

    // 현재 탭 추가
    state = [...state, now];

    // 1초 내에 3번 탭되었는지 확인
    if (state.length >= 3) {
      state = []; // 탭 기록 초기화
      action(); // 콜백 실행
    }
  }

  void reset() {
    state = [];
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'triple_tap_state.g.dart';

@riverpod
class TripleTapState extends _$TripleTapState {
  @override
  List<DateTime> build() {
    return [];
  }

  void registerTap(void Function() action) {
    final now = DateTime.now();

    state = state.where((tapTime) => now.difference(tapTime) <= const Duration(seconds: 1)).toList();
    state = [...state, now];

    if (state.length >= 3) {
      state = [];
      action();
    }
  }

  void reset() {
    state = [];
  }
}

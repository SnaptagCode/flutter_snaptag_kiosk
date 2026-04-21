import 'package:flutter_snaptag_kiosk/core/data/datasources/local/local_db_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_count_provider.g.dart';

class CardCountState {
  final int initialCount;
  final int currentCount;

  const CardCountState({
    required this.initialCount,
    required this.currentCount,
  });

  int get usedCount => (initialCount - currentCount).clamp(0, initialCount);
  int get remaining => currentCount;

  CardCountState copyWith({int? initialCount, int? currentCount}) {
    return CardCountState(
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }

  String get remainingSingleSidedCount => '$currentCount / $initialCount';

  factory CardCountState.initial([int n = 0]) => CardCountState(initialCount: n, currentCount: n);
}

@Riverpod(keepAlive: true)
class CardCount extends _$CardCount {
  @override
  CardCountState build() => CardCountState.initial(0);

  void setInitial(int value) {
    state = state.copyWith(initialCount: value);
  }

  void updateCurrent(int newCount) {
    state = state.copyWith(currentCount: newCount);
  }

  void update(int value) {
    state = state.copyWith(initialCount: value, currentCount: value);
  }

  Future<void> increase([int step = 1]) async {
    final next = state.currentCount + step;
    state = state.copyWith(currentCount: next);
  }

  Future<void> decrease({required bool isSingle, int step = 1}) async {
    final next = (state.currentCount - step).clamp(0, state.initialCount);
    state = state.copyWith(currentCount: next);
    try {
      await ref.read(localDbServiceProvider).writePrintLog(isSingle: isSingle);
    } catch (_) {}
  }
}

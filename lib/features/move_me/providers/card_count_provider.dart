import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_count_provider.g.dart';

/// 카드 수량 상태 모델
class CardCountState {
  final int initialCount; // 처음 설정(기준) 수량
  final int currentCount; // 현재 수량

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

  factory CardCountState.initial([int n = 0]) =>
      CardCountState(initialCount: n, currentCount: n);
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

  void increase([int step = 1]) {
    state = state.copyWith(currentCount: state.currentCount + step);
  }

  void decrease([int step = 1]) {
    final next = state.currentCount - step;
    state = state.copyWith(currentCount: next < 0 ? 0 : next);
  }
}

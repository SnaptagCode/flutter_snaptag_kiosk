import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_count_provider.g.dart';

@Riverpod(keepAlive: true)
class CardCount extends _$CardCount {
  @override
  int build() => 0; // 초기 카드 수

  void increase() => state++;

  void decrease() {
    if (state > 0) state--;
  }

  void update(int newCount) {
    state = newCount;
  }
}

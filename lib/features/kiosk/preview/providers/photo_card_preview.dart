import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_card_preview.g.dart';

@riverpod
class PhotoCardPreview extends _$PhotoCardPreview {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> payment() async {
    state = const AsyncValue.loading();

    await Future.delayed(const Duration(seconds: 2));

    state = await AsyncValue.guard(() async {
      if (DateTime.now().second % 2 == 0) {
        return;
      } else {
        throw '결제 실패: 테스트 에러 메시지';
      }
    });
  }

  // 테스트용 메소드들
  Future<void> simulateSuccess() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 2));
    state = const AsyncValue.data(null);
  }

  Future<void> simulateError() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 2));
    state = AsyncValue.error('강제 에러 발생', StackTrace.current);
  }
}

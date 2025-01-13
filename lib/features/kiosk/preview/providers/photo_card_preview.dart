import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_card_preview.g.dart';

@riverpod
class PhotoCardPreview extends _$PhotoCardPreview {
  @override
  FutureOr<int> build() {
    return 0;
  }

  Future<void> payment() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => Future.value(0));
  }
}

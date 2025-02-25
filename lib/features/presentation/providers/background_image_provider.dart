import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_image_provider.g.dart';

@riverpod
class BackgroundImage extends _$BackgroundImage {
  @override
  bool build() => false; // networkError 상태를 관리, 초기값은 false

  void setNetworkError() {
    state = true;
  }
}

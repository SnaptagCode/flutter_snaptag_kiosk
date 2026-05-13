import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'back_photo_session_notifier.g.dart';

@Riverpod(keepAlive: true)
class BackPhotoSession extends _$BackPhotoSession {
  @override
  AsyncValue<BackPhotoCardResponse?> build() {
    return const AsyncValue.data(null);
  }

  void updateState(BackPhotoCardResponse? response) {
    state = AsyncValue.data(response);
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

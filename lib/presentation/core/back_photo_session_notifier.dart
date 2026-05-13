import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'back_photo_session_notifier.g.dart';

@Riverpod(keepAlive: true)
class BackPhotoSession extends _$BackPhotoSession {
  @override
  AsyncValue<BackPhotoCard?> build() {
    return const AsyncValue.data(null);
  }

  void updateState(BackPhotoCard? card) {
    state = AsyncValue.data(card);
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

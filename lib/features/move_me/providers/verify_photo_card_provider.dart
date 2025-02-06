import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_photo_card_provider.g.dart';

@Riverpod(keepAlive: true)
class VerifyPhotoCard extends _$VerifyPhotoCard {
  @override
  AsyncValue<BackPhotoCardResponse?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> verify(String code) async {
    if (code.length != AuthCode.maxLength) {
      throw Exception('Invalid code length');
    }

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final kioskEventId = ref.read(storageServiceProvider).settings.kioskEventId;

      final response = await ref.read(kioskRepositoryProvider).getBackPhotoCard(
            kioskEventId,
            code,
          );
      FileLogger.info('BackPhotoCardResponse: ${response.toJson()}');
      return response;
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

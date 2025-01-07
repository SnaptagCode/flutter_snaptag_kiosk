import 'package:flutter/widgets.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_code_provider.g.dart';

@riverpod
class AuthCode extends _$AuthCode {
  static const int maxLength = 4;

  @override
  String build() {
    return '';
  }

  void addNumber(String number) {
    if (state.length < maxLength) {
      final newInput = state + number;
      state = newInput;
    }
  }

  void removeLast() {
    if (state.isNotEmpty) {
      final newInput = state.substring(0, state.length - 1);
      state = newInput;
    }
  }

  void clear() {
    state = '';
  }

  Future<void> submit(BuildContext _) async {
    BuildContext context = contentsNavigatorKey.currentContext!;
    context.loaderOverlay.show();
    try {
      if (state.length == maxLength) {
        final BackPhotoCardResponse response = await ref.read(kioskRepositoryProvider).getBackPhotoCard(
              ref.watch(storageServiceProvider).settings.kioskEventId,
              state,
            );
        logger.d('BackPhotoCardResponse: ${response.toJson()}');
      } else {
        throw Exception('Invalid code length');
      }
    } catch (msg, stacktrace) {
      await DialogHelper.showErrorDialog();
      logger.e('Error submitting auth code: $msg stacktrace $stacktrace');
    } finally {
      context.loaderOverlay.hide();
      clear();
    }
  }
}

import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/common/log/app_log_service.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/verify_photo_card_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_card_preview_screen_provider.g.dart';

@riverpod
class PhotoCardPreviewScreenProvider extends _$PhotoCardPreviewScreenProvider {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  static List<File> _getLocalBackPhotos() {
    final dir = Directory(p.join(p.dirname(Platform.resolvedExecutable), 'image', 'back_photos'));
    if (!dir.existsSync()) return [];
    return dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final lower = f.path.toLowerCase();
          return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
        })
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  Future<void> payment() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      await ref.read(printerServiceProvider.notifier).checkFeeder();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return;
    }

    try {
      final selection = ref.read(backPhotoTypeProvider);
      final selectedIndex = selection?.fixedIndex ?? 0;
      final kiosk = ref.read(kioskInfoServiceProvider);

      final files = _getLocalBackPhotos();
      final localFile = files.isNotEmpty && selectedIndex < files.length ? files[selectedIndex] : null;
      final localPath = localFile?.path ?? '';

      ref.read(verifyPhotoCardProvider.notifier).updateState(BackPhotoCardResponse(
            kioskEventId: kiosk?.kioskEventId ?? 1,
            backPhotoCardId: selectedIndex,
            backPhotoCardOriginUrl: localPath,
            photoAuthNumber: 'LOCAL',
            formattedBackPhotoCardUrl: localPath,
          ));

      final backName = localFile != null ? p.basename(localFile.path) : '-';
      AppLogService.instance.info('출력 시작 - back: $backName');

      final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);
      timeoutNotifier.cancelTimerWithCallback();

      await ref.read(paymentServiceProvider.notifier).processPayment();

      AppLogService.instance.info('출력 성공');
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      AppLogService.instance.error('출력 실패 - $e');
      if (e is! OrderCreationException && e is! PreconditionFailedException) {
        try {
          AppLogService.instance.error('출력 실패로 환불 시작: $e');
          await ref.read(paymentServiceProvider.notifier).refund();
          if (ref.read(pagePrintProvider) == PagePrintType.single) {
            await ref.read(cardCountProvider.notifier).increase();
          }
        } catch (refundError) {
          logger.e('Payment and refund failed', error: refundError);
        }
      }
      state = AsyncValue.error(e, stack);
    }
  }
}

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_snaptag_kiosk/core/common/log/app_log_service.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/verify_photo_card_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_card_preview_screen_provider.g.dart';

@riverpod
class PhotoCardPreviewScreenProvider extends _$PhotoCardPreviewScreenProvider {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  static File? _getBackPhotoForToday() {
    final dir = Directory(p.join(p.dirname(Platform.resolvedExecutable), 'image', 'back_photos'));
    if (!dir.existsSync()) return null;
    final dateStr = DateFormat('yyMMdd').format(DateTime.now());
    return dir.listSync().whereType<File>().firstWhereOrNull((f) {
      final name = p.basenameWithoutExtension(f.path.toLowerCase());
      return name == dateStr;
    });
  }

  static String _getEmbedFilePath(File uiFile) {
    final dir = p.dirname(uiFile.path);
    final baseName = p.basename(uiFile.path);
    final embedFile = File(p.join(dir, 'embed_$baseName'));
    return embedFile.existsSync() ? embedFile.path : uiFile.path;
  }

  static String _getOriginPhotoPath(String backPhotosDir) {
    final file = File(p.join(backPhotosDir, 'origin_photo.png'));
    return file.existsSync() ? file.path : '';
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
      final kiosk = ref.read(kioskInfoServiceProvider);

      final localFile = _getBackPhotoForToday();
      if (localFile == null) {
        state = AsyncValue.error(BackPhotoNotFoundException(), StackTrace.current);
        return;
      }

      final originPath = _getOriginPhotoPath(p.dirname(localFile.path));
      final displayPath = originPath.isNotEmpty ? originPath : localFile.path;
      final embedPath = _getEmbedFilePath(localFile);

      ref.read(verifyPhotoCardProvider.notifier).updateState(BackPhotoCardResponse(
            kioskEventId: kiosk?.kioskEventId ?? 1,
            backPhotoCardId: 0,
            backPhotoCardOriginUrl: displayPath,
            photoAuthNumber: 'LOCAL',
            formattedBackPhotoCardUrl: embedPath,
          ));

      final backName = p.basename(localFile.path);
      AppLogService.instance.info('출력 시작 - back: $backName');

      final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);
      timeoutNotifier.cancelTimerWithCallback();

      await ref.read(paymentServiceProvider.notifier).processPayment();

      AppLogService.instance.info('결제 완료 - 인쇄 화면으로 이동');
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

class BackPhotoNotFoundException implements Exception {}

import 'dart:io';
import 'dart:math';

import 'package:flutter_snaptag_kiosk/core/data/datasources/local/local_db_service.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_service.g.dart';

@riverpod
class PrintService extends _$PrintService {
  @override
  FutureOr<void> build() => null;

  Future<void> printCard() async {
    try {
      await _handlePrintProcess();
    } catch (e, stack) {
      logger.e('PrintService.print failure', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _handlePrintProcess() async {
    // 단면 수량이 0이면 자동으로 양면 전환
    if (ref.read(pagePrintProvider) == PagePrintType.single &&
        ref.read(cardCountProvider).currentCount <= 0) {
      ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
    }

    // 1. 앞면 이미지 준비
    final frontPhotoInfo = await _prepareFrontPhoto();

    // 2. 뒷면 이미지 준비 (로컬 back_photos 폴더에서 랜덤 선택)
    final backPhotoFile = await _pickRandomBackPhoto();

    // 3. 프린트 진행 및 상태 업데이트
    await _executePrintJob(1, frontPhotoInfo.safeEmbedImage, backPhotoFile);
  }

  Future<NominatedPhoto> _prepareFrontPhoto() async {
    return await ref.read(frontPhotoListProvider.notifier).getRandomPhoto();
  }

  Future<File> _pickRandomBackPhoto() async {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    final backPhotosDir = Directory(p.join(exeDir, 'image', 'back_photos'));

    if (!await backPhotosDir.exists()) {
      throw Exception('image/back_photos/ 폴더를 찾을 수 없습니다: ${backPhotosDir.path}');
    }

    final files = await backPhotosDir
        .list()
        .where((e) => e is File && _isImageFile(e.path))
        .cast<File>()
        .toList();

    if (files.isEmpty) {
      throw Exception('image/back_photos/ 폴더에 이미지가 없습니다');
    }

    return files[Random().nextInt(files.length)];
  }

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
  }

  Future<void> _executePrintJob(int printedPhotoCardId, File? frontPhoto, File embedded) async {
    try {
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.started);

      final isSingleSidedMode = ref.read(pagePrintProvider) == PagePrintType.single;
      if (isSingleSidedMode) {
        await _executePrint(frontPhoto: null, embedded: embedded);
      } else {
        await _executePrint(frontPhoto: frontPhoto, embedded: embedded);
      }

      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.completed);
      final isSingle = ref.read(pagePrintProvider) == PagePrintType.single;
      await ref.read(cardCountProvider.notifier).decrease(isSingle: isSingle);
    } catch (e, stack) {
      logger.e('PrintService._executePrintJob failure', error: e, stackTrace: stack);
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.failed);
      await ref.read(localDbServiceProvider).writeErrorLog('[인쇄 실패] $e');
      rethrow;
    }
  }

  Future<void> _updatePrintStatus(int printedPhotoCardId, PrintedStatus status) async {
    try {
      final request = UpdatePrintRequest(
        kioskMachineId: ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0,
        kioskEventId: ref.read(kioskInfoServiceProvider)?.kioskEventId ?? 0,
        status: status,
      );
      await ref.read(kioskRepositoryProvider).updatePrintStatus(
            printedPhotoCardId: printedPhotoCardId,
            request: request,
          );
    } catch (e) {
      logger.e('PrintService._updatePrintStatus failure', error: e);
    }
  }

  Future<void> _executePrint({File? frontPhoto, required File embedded}) async {
    try {
      await ref.read(printerServiceProvider.notifier).printImage(
            frontFile: frontPhoto,
            embeddedFile: embedded,
            isSingleMode: ref.read(pagePrintProvider) == PagePrintType.single,
          );
    } catch (e) {
      rethrow;
    }
  }
}

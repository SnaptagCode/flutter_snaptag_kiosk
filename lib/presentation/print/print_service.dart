import 'dart:io';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_response_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/verify_photo_card_provider.dart';
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
    // 1. 사전 검증
    _validatePrintRequirements();

    // 2. 프론트 이미지 준비
    final frontPhotoInfo = await _prepareFrontPhoto();

    // 3. 프린트 작업 생성 및 백 이미지 준비
    final printJobInfo = await _createPrintJobWithEmbeddingBackImage(
      frontPhotoCardId: frontPhotoInfo.id,
      backPhotoCardId: ref.read(verifyPhotoCardProvider).value?.backPhotoCardId ?? 0,
    );

    // 4. 프린트 진행 및 상태 업데이트
    await _executePrintJob(
      printJobInfo.printedPhotoCardId,
      frontPhotoInfo.safeEmbedImage,
      printJobInfo.backPhotoFile,
    );
  }

  Future<void> _executePrintJob(int printedPhotoCardId, File frontPhoto, File embedded) async {
    try {
      if (printedPhotoCardId != 0) {
        await _updatePrintStatus(printedPhotoCardId, PrintedStatus.started);
      }

      final isSingleSidedMode = ref.read(pagePrintProvider) == PagePrintType.single;
      if (isSingleSidedMode) {
        await _executePrint(frontPhoto: null, embedded: embedded);
      } else {
        await _executePrint(frontPhoto: frontPhoto, embedded: embedded);
      }

      if (printedPhotoCardId != 0) {
        await _updatePrintStatus(printedPhotoCardId, PrintedStatus.completed);
      }
    } catch (e, stack) {
      logger.e('PrintService._executePrintJob failure', error: e, stackTrace: stack);
      if (printedPhotoCardId != 0) {
        await _updatePrintStatus(printedPhotoCardId, PrintedStatus.failed);
      }
      rethrow;
    }
  }

  Future<NominatedPhoto> _prepareFrontPhoto() async {
    final frontPhotoList = ref.read(frontPhotoListProvider.notifier);
    final randomPhoto = await frontPhotoList.getRandomPhoto();

    return randomPhoto;
  }

  void _validatePrintRequirements() {
    final backPhotoCardResponseInfo = ref.read(verifyPhotoCardProvider).value;
    final approvalInfo = ref.read(paymentResponseStateProvider);
    final printerState = ref.read(printerServiceProvider);

    if (backPhotoCardResponseInfo == null) throw Exception('No back photo card response info available');
    if (approvalInfo == null) throw Exception('No payment approval info available');
    // if (printerState.hasError) throw Exception('Printer is not ready');
  }

  Future<
      ({
        int printedPhotoCardId,
        File backPhotoFile,
      })> _createPrintJobWithEmbeddingBackImage({
    required int frontPhotoCardId,
    required int backPhotoCardId,
  }) async {
    // 로컬 파일 경로가 있으면 API 호출 없이 바로 사용
    // 원본 파일 보호를 위해 임시 복사본을 만들어 전달 (출력 후 삭제 대상은 복사본)
    final localBackPath = ref.read(verifyPhotoCardProvider).value?.formattedBackPhotoCardUrl ?? '';
    if (localBackPath.isNotEmpty) {
      final localFile = File(localBackPath);
      if (localFile.existsSync()) {
        final ext = p.extension(localFile.path);
        final tempFile = File('${Directory.systemTemp.path}/snaptag_back_${DateTime.now().millisecondsSinceEpoch}$ext');
        await localFile.copy(tempFile.path);
        return (printedPhotoCardId: 0, backPhotoFile: tempFile);
      }
    }

    throw Exception('No local back photo file available');
  }

  Future<void> _updatePrintStatus(int printedPhotoCardId, PrintedStatus status) async {
    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final request = UpdatePrintRequest(
          kioskMachineId: ref.read(kioskInfoServiceProvider)!.kioskMachineId,
          kioskEventId: ref.read(kioskInfoServiceProvider)!.kioskEventId,
          status: status,
        );

        await ref
            .read(kioskRepositoryProvider)
            .updatePrintStatus(printedPhotoCardId: printedPhotoCardId, request: request);
        return;
      } catch (e) {
        attempt++;
        // logger.w('PrintService._updatePrintStatus attempt $attempt/$maxRetries failure', error: e);

        if (attempt >= maxRetries) {
          final kioskInfo = ref.read(kioskInfoServiceProvider);
          final machineId = kioskInfo?.kioskMachineId ?? 0;
          final machineName = kioskInfo?.kioskMachineName ?? '';
          SlackLogService().sendErrorLogToSlack(
              '[MACHINE_NAME: $machineName (MACHINE_ID: $machineId)] PrintService._updatePrintStatus failure after $maxRetries retries: $e');
          logger.e('PrintService._updatePrintStatus failure', error: e);
          return;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  Future<void> _executePrint({
    File? frontPhoto,
    required File embedded,
  }) async {
    try {
      await ref.read(printerServiceProvider.notifier).printImage(
            frontFile: frontPhoto,
            embeddedFile: embedded,
            isSingleMode: ref.read(pagePrintProvider) == PagePrintType.single,
          );
    } catch (e) {
      rethrow;
    } finally {
      if (await embedded.exists()) {
        await embedded.delete();
      }
    }
  }
}

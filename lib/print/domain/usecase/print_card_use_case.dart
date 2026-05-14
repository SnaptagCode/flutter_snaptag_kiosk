import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';

class PrintCardUseCase {
  PrintCardUseCase(this._ref);
  final Ref _ref;

  Future<void> call() async {
    try {
      await _handlePrintProcess();
    } catch (e, stack) {
      logger.e('PrintCardUseCase failure', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _handlePrintProcess() async {
    _validatePrintRequirements();

    final frontPhotoInfo = await _prepareFrontPhoto();

    final printJobInfo = await _createPrintJobWithEmbeddingBackImage(
      frontPhotoCardId: frontPhotoInfo.id,
      backPhotoCardId: _ref.read(backPhotoSessionProvider).value?.backPhotoCardId ?? 0,
    );

    await _executePrintJob(
      printJobInfo.printedPhotoCardId,
      frontPhotoInfo.safeEmbedImage,
      printJobInfo.backPhotoFile,
    );
  }

  Future<void> _executePrintJob(int printedPhotoCardId, File frontPhoto, File embedded) async {
    try {
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.started);

      final isSingleSidedMode = _ref.read(pagePrintProvider) == PagePrintType.single;
      if (isSingleSidedMode) {
        await _executePrint(frontPhoto: null, embedded: embedded);
      } else {
        await _executePrint(frontPhoto: frontPhoto, embedded: embedded);
      }

      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.completed);
    } catch (e, stack) {
      logger.e('PrintCardUseCase._executePrintJob failure', error: e, stackTrace: stack);
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.failed);
      rethrow;
    }
  }

  Future<NominatedPhoto> _prepareFrontPhoto() async {
    final frontPhotoList = _ref.read(frontPhotoListProvider.notifier);
    return await frontPhotoList.getRandomPhoto();
  }

  void _validatePrintRequirements() {
    final backPhotoCardResponseInfo = _ref.read(backPhotoSessionProvider).value;
    final approvalInfo = _ref.read(paymentResponseStateProvider);

    if (backPhotoCardResponseInfo == null) throw Exception('No back photo card response info available');
    if (approvalInfo == null) throw Exception('No payment approval info available');
  }

  Future<({int printedPhotoCardId, File backPhotoFile})> _createPrintJobWithEmbeddingBackImage({
    required int frontPhotoCardId,
    required int backPhotoCardId,
  }) async {
    try {
      final kioskOrderId = _ref.read(createOrderInfoProvider)?.orderId ?? 0;
      final request = CreatePrintRequest(
        kioskMachineId: _ref.read(kioskInfoServiceProvider)!.kioskMachineId,
        kioskEventId: _ref.read(kioskInfoServiceProvider)!.kioskEventId,
        frontPhotoCardId: frontPhotoCardId,
        backPhotoCardId: backPhotoCardId,
        kioskOrderId: kioskOrderId,
      );

      final response = await _ref.read(kioskRepositoryProvider).createPrintStatus(request: request);
      final backPhotoFile = await ImageHelper().convertImageUrlToFile(response.formattedImageUrl);

      return (printedPhotoCardId: response.printedPhotoCardId, backPhotoFile: backPhotoFile);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updatePrintStatus(int printedPhotoCardId, PrintedStatus status) async {
    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final request = UpdatePrintRequest(
          kioskMachineId: _ref.read(kioskInfoServiceProvider)!.kioskMachineId,
          kioskEventId: _ref.read(kioskInfoServiceProvider)!.kioskEventId,
          status: status,
        );

        await _ref.read(kioskRepositoryProvider).updatePrintStatus(
              printedPhotoCardId: printedPhotoCardId,
              request: request,
            );
        return;
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          final kioskInfo = _ref.read(kioskInfoServiceProvider);
          final machineId = kioskInfo?.kioskMachineId ?? 0;
          final machineName = kioskInfo?.kioskMachineName ?? '';
          SlackLogService().sendErrorLogToSlack(
              '[MACHINE_NAME: $machineName (MACHINE_ID: $machineId)] PrintCardUseCase._updatePrintStatus failure after $maxRetries retries: $e');
          logger.e('PrintCardUseCase._updatePrintStatus failure', error: e);
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
      await _ref.read(printerServiceProvider.notifier).printImage(
            frontFile: frontPhoto,
            embeddedFile: embedded,
            isSingleMode: _ref.read(pagePrintProvider) == PagePrintType.single,
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

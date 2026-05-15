import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/domain/models/enums/printed_status.dart';
import 'package:flutter_snaptag_kiosk/domain/models/print/create_print_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/print/update_print_params.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_kiosk_print_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_front_photo_service.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_printer_service.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/domain/usecase.dart';

class PrintCardParams {
  final int backPhotoCardId;
  final int kioskOrderId;
  final int kioskMachineId;
  final int kioskEventId;
  final String kioskMachineName;
  final bool isSingleMode;

  const PrintCardParams({
    required this.backPhotoCardId,
    required this.kioskOrderId,
    required this.kioskMachineId,
    required this.kioskEventId,
    required this.kioskMachineName,
    required this.isSingleMode,
  });
}

class PrintCardUseCase implements UseCase<void, PrintCardParams> {
  final IFrontPhotoService _frontPhotoService;
  final IPrinterService _printerService;
  final IKioskPrintRepository _printRepository;
  final ISlackLogService _slackLog;
  final IImageConverter _imageConverter;

  PrintCardUseCase({
    required IFrontPhotoService frontPhotoService,
    required IPrinterService printerService,
    required IKioskPrintRepository printRepository,
    required ISlackLogService slackLog,
    required IImageConverter imageConverter,
  })  : _frontPhotoService = frontPhotoService,
        _printerService = printerService,
        _printRepository = printRepository,
        _slackLog = slackLog,
        _imageConverter = imageConverter;

  @override
  Future<void> call(PrintCardParams params) async {
    try {
      await _handlePrintProcess(params);
    } catch (e, stack) {
      logger.e('PrintCardUseCase failure', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _handlePrintProcess(PrintCardParams params) async {
    final frontPhotoInfo = await _frontPhotoService.getRandomPhoto();

    final printJobInfo = await _createPrintJobWithEmbeddingBackImage(
      params: params,
      frontPhotoCardId: frontPhotoInfo.id,
    );

    await _executePrintJob(
      params: params,
      printedPhotoCardId: printJobInfo.printedPhotoCardId,
      frontPhoto: frontPhotoInfo.embedImage,
      embedded: printJobInfo.backPhotoFile,
    );
  }

  Future<void> _executePrintJob({
    required PrintCardParams params,
    required int printedPhotoCardId,
    required File frontPhoto,
    required File embedded,
  }) async {
    try {
      await _updatePrintStatus(params, printedPhotoCardId, PrintedStatus.started);

      if (params.isSingleMode) {
        await _executePrint(frontPhoto: null, embedded: embedded, isSingleMode: true);
      } else {
        await _executePrint(frontPhoto: frontPhoto, embedded: embedded, isSingleMode: false);
      }

      await _updatePrintStatus(params, printedPhotoCardId, PrintedStatus.completed);
    } catch (e, stack) {
      logger.e('PrintCardUseCase._executePrintJob failure', error: e, stackTrace: stack);
      await _updatePrintStatus(params, printedPhotoCardId, PrintedStatus.failed);
      rethrow;
    }
  }

  Future<({int printedPhotoCardId, File backPhotoFile})> _createPrintJobWithEmbeddingBackImage({
    required PrintCardParams params,
    required int frontPhotoCardId,
  }) async {
    final createParams = CreatePrintParams(
      kioskMachineId: params.kioskMachineId,
      kioskEventId: params.kioskEventId,
      frontPhotoCardId: frontPhotoCardId,
      backPhotoCardId: params.backPhotoCardId,
      kioskOrderId: params.kioskOrderId,
    );

    final response = await _printRepository.createPrintStatus(params: createParams);
    final backPhotoFile = await _imageConverter.convertImageUrlToFile(response.formattedImageUrl);

    return (printedPhotoCardId: response.printedPhotoCardId, backPhotoFile: backPhotoFile);
  }

  Future<void> _updatePrintStatus(PrintCardParams params, int printedPhotoCardId, PrintedStatus status) async {
    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final updateParams = UpdatePrintParams(
          kioskMachineId: params.kioskMachineId,
          kioskEventId: params.kioskEventId,
          status: status,
        );

        await _printRepository.updatePrintStatus(
          printedPhotoCardId: printedPhotoCardId,
          params: updateParams,
        );
        return;
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          _slackLog.sendErrorLog(
              '[MACHINE_NAME: ${params.kioskMachineName} (MACHINE_ID: ${params.kioskMachineId})] PrintCardUseCase._updatePrintStatus failure after $maxRetries retries: $e');
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
    required bool isSingleMode,
  }) async {
    try {
      await _printerService.printImage(
        frontFile: frontPhoto,
        embeddedFile: embedded,
        isSingleMode: isSingleMode,
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

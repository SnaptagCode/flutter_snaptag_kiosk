import 'dart:io';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_service.g.dart';

@riverpod
class PrintService extends _$PrintService {
  @override
  FutureOr<void> build() => null;

  Future<void> print() async {
    try {
      // 1. 사전 검증
      _validatePrintRequirements();

      // 2. 이미지 준비
      final frontPhotoInfo = await _prepareFrontPhoto();
      final embeddedBackImage = await _prepareBackImage();

      // 3. 프린트 작업 생성
      final printJobInfo = await _createPrintJob(
        frontPhotoCardId: frontPhotoInfo.id,
        backPhotoCardId: ref.read(verifyPhotoCardProvider).value?.backPhotoCardId ?? 0,
        file: embeddedBackImage,
      );

      try {
        // 4. 프린트 상태 업데이트 (시작)
        await _updatePrintStatus(
          printJobInfo.printedPhotoCardId,
          PrintedStatus.started,
        );

        // 5. 실제 프린트 실행
        await _executePrint(
          frontPhotoPath: frontPhotoInfo.path,
          embedded: embeddedBackImage,
        );

        // 6. 프린트 상태 업데이트 (완료)
        await _updatePrintStatus(
          printJobInfo.printedPhotoCardId,
          PrintedStatus.completed,
        );
      } catch (e, stack) {
        // 프린트 실패 처리
        await _handlePrintFailure(printJobInfo.printedPhotoCardId, e, stack);
        rethrow;
      }
    } catch (e) {
      logger.e('Print process failed', error: e);
      rethrow;
    }
  }

  Future<({String path, int id})> _prepareFrontPhoto() async {
    final frontPhotoList = ref.read(frontPhotoListProvider.notifier);
    final randomPhoto = await frontPhotoList.getRandomPhoto();

    if (randomPhoto == null) {
      throw Exception('No front images available');
    }

    return (
      path: randomPhoto.path,
      id: randomPhoto.id,
    );
  }

  Future<File> _prepareBackImage() async {
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;
    if (backPhoto == null) {
      throw Exception('No back photo available');
    }
    final config = ref.watch(backPhotoForPrintInfoProvider);

    try {
      final response = await ImageHelper().getImageBytes(backPhoto.formattedBackPhotoCardUrl);

      final processedImage = await ref.read(labcurityServiceProvider).embedImage(
            response.data,
            LabcurityImageConfig(
              size: 3,
              strength: 16,
              alphaCode: config?.versionCode ?? 1,
              bravoCode: config?.countryCode ?? 0,
              charlieCode: config?.industryCode ?? 0,
              deltaCode: config?.customerCode ?? 0,
              echoCode: config?.projectCode ?? 0,
              foxtrotCode: config?.productCode ?? 1,
            ),
          );

      if (processedImage == null) {
        throw Exception('Failed to process back image with Labcurity');
      }

      final tempFile = File('${DateTime.now().millisecondsSinceEpoch}_processed.png');
      await tempFile.writeAsBytes(processedImage);

      return tempFile;
    } catch (e) {
      throw Exception('Failed to prepare back image: ${e.toString()}');
    }
  }

  void _validatePrintRequirements() {
    final backPhotoForPrintInfo = ref.read(backPhotoForPrintInfoProvider);
    if (backPhotoForPrintInfo == null) {
      throw Exception('No back photo for print info available');
    }

    final backPhotoCardResponseInfo = ref.watch(verifyPhotoCardProvider).value;
    if (backPhotoCardResponseInfo == null) {
      throw Exception('No back photo card response info available');
    }

    final approvalInfo = ref.read(paymentResponseStateProvider);
    if (approvalInfo == null) {
      throw Exception('No payment approval info available');
    }

    final printerState = ref.read(printerStateProvider);
    if (printerState.hasError) {
      throw Exception('Printer is not ready');
    }
  }

  Future<({int printedPhotoCardId})> _createPrintJob({
    required int frontPhotoCardId,
    required int backPhotoCardId,
    required File file,
  }) async {
    try {
      final request = CreatePrintRequest(
        kioskMachineId: ref.watch(storageServiceProvider).settings.kioskMachineId,
        kioskEventId: ref.watch(storageServiceProvider).settings.kioskEventId,
        frontPhotoCardId: frontPhotoCardId,
        backPhotoCardId: backPhotoCardId,
        file: file,
      );

      final response = await ref.read(kioskRepositoryProvider).createPrintStatus(request: request);
      return (printedPhotoCardId: response.printedPhotoCardId);
    } catch (e) {
      throw Exception('Failed to create print job');
    }
  }

  Future<void> _updatePrintStatus(int printedPhotoCardId, PrintedStatus status) async {
    try {
      final request = UpdatePrintRequest(
        kioskMachineId: ref.watch(storageServiceProvider).settings.kioskMachineId,
        kioskEventId: ref.watch(storageServiceProvider).settings.kioskEventId,
        status: status,
      );

      await ref
          .read(kioskRepositoryProvider)
          .updatePrintStatus(printedPhotoCardId: printedPhotoCardId, request: request);
    } catch (e) {
      throw Exception('Failed to update print status');
    }
  }

  Future<void> _executePrint({
    required String frontPhotoPath,
    required File embedded,
  }) async {
    try {
      await ref.read(printerStateProvider.notifier).printImage(
            frontImagePath: frontPhotoPath,
            embeddedFile: embedded,
          );
    } catch (e) {
      throw Exception('Failed to execute print');
    } finally {
      if (await embedded.exists()) {
        await embedded.delete();
      }
    }
  }

  Future<void> _handlePrintFailure(
    int printedPhotoCardId,
    Object error,
    StackTrace stack,
  ) async {
    logger.e('Print failure', error: error, stackTrace: stack);

    try {
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.failed);
      // 환불 진행은 PrintProcessScreen에서 처리
    } catch (e) {
      logger.e('Failed to handle print failure', error: e);
      rethrow;
    }
  }
}

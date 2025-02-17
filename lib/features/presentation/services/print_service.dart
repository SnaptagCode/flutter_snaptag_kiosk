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

    // 3. 백 이미지 준비
    final embeddedBackImage = await _prepareBackImage();

    // 4. 프린트 작업 생성
    final printJobInfo = await _createPrintJob(
      frontPhotoCardId: frontPhotoInfo.id,
      backPhotoCardId: ref.read(verifyPhotoCardProvider).value?.backPhotoCardId ?? 0,
      file: embeddedBackImage,
    );

    // 5. 프린트 진행 및 상태 업데이트
    await _executePrintJob(
      printJobInfo.printedPhotoCardId,
      frontPhotoInfo.path,
      embeddedBackImage,
    );
  }

  Future<void> _executePrintJob(int printedPhotoCardId, String frontPhotoPath, File embedded) async {
    try {
      // 프린트 상태 시작
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.started);

      // 실제 프린트 실행
      await _executePrint(frontPhotoPath: frontPhotoPath, embedded: embedded);

      // 프린트 상태 완료
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.completed);
    } catch (e, stack) {
      logger.e('PrintService._executePrintJob failure', error: e, stackTrace: stack);
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.failed);
      rethrow;
    }
  }

  Future<({String path, int id, bool isWin})> _prepareFrontPhoto() async {
    final frontPhotoList = ref.read(frontPhotoListProvider.notifier);
    final randomPhoto = await frontPhotoList.getRandomPhoto();

    return (path: randomPhoto.path, id: randomPhoto.id, isWin: randomPhoto.isWin);
  }

  Future<File> _prepareBackImage() async {
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;
    if (backPhoto == null) {
      throw Exception('No back photo available');
    }
    final config = ref.watch(backPhotoForPrintInfoProvider);

    try {
      final response = await ImageHelper().getImageBytes(backPhoto.formattedBackPhotoCardUrl);

      final File processedImage = await ref.read(labcurityServiceProvider).embedImage(
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

      return processedImage;
    } catch (e) {
      rethrow;
    }
  }

  void _validatePrintRequirements() {
    final backPhotoForPrintInfo = ref.read(backPhotoForPrintInfoProvider);
    final backPhotoCardResponseInfo = ref.watch(verifyPhotoCardProvider).value;
    final approvalInfo = ref.read(paymentResponseStateProvider);
    final printerState = ref.read(printerServiceProvider);

    if (backPhotoForPrintInfo == null) throw Exception('No back photo for print info available');
    if (backPhotoCardResponseInfo == null) throw Exception('No back photo card response info available');
    if (approvalInfo == null) throw Exception('No payment approval info available');
    if (printerState.hasError) throw Exception('Printer is not ready');
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
      rethrow;
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
      rethrow;
    }
  }

  Future<void> _executePrint({
    required String frontPhotoPath,
    required File embedded,
  }) async {
    try {
      await ref.read(printerServiceProvider.notifier).printImage(
            frontImagePath: frontPhotoPath,
            embeddedFile: embedded,
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

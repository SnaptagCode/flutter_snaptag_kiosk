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
      // 사전 검증
      // throw Exception('Printer not ready');
      _validatePrintRequirements();

      // 프론트 이미지
      final frontPhotoInfo = await _prepareFrontPhoto();
      // throw Exception('No front images available');

      // 백 이미지 다운로드/처리
      final embeddedBackImage = await _prepareBackImage();
      // throw Exception('Failed to download back image');

      // 프린트 작업 생성
      // throw Exception('Failed to create print job');
      final printJobInfo = await _createPrintJob(
        frontPhotoCardId: frontPhotoInfo.id,
        backPhotoCardId: ref.read(verifyPhotoCardProvider).value?.backPhotoCardId ?? 0,
        file: embeddedBackImage,
      );

      try {
        // 4. 프린트 상태 업데이트 (시작)
        // throw Exception('Failed to update print status');
        await _updatePrintStatus(
          printJobInfo.printedPhotoCardId,
          PrintedStatus.started,
        );

        // 5. 실제 프린트 실행
        // throw Exception('Failed to execute print');
        await _executePrint(
          frontPhotoPath: frontPhotoInfo.path,
          embedded: embeddedBackImage,
        );

        // 6. 프린트 상태 업데이트 (완료)
        // throw Exception('Failed to update print status');
        await _updatePrintStatus(
          printJobInfo.printedPhotoCardId,
          PrintedStatus.completed,
        );
      } catch (e, stack) {
        // 프린트 실패 처리
        FileLogger.warning('Print failure', error: e, stackTrace: stack);
        await _updatePrintStatus(printJobInfo.printedPhotoCardId, PrintedStatus.failed);
        rethrow;
      }
    } catch (e) {
      FileLogger.warning('Print process failed', error: e);
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

    final printerState = ref.read(printerServiceProvider);
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

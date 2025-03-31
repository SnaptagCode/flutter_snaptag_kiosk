import 'dart:io';

import 'package:flutter_snaptag_kiosk/lib.dart';
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
      // 프린트 상태 시작
      //await _updatePrintStatus(printedPhotoCardId, PrintedStatus.started);

      // 실제 프린트 실행
      await _executePrint(frontPhoto: frontPhoto, embedded: embedded);

      // 프린트 상태 완료
      //await _updatePrintStatus(printedPhotoCardId, PrintedStatus.completed);
    } catch (e, stack) {
      logger.e('PrintService._executePrintJob failure', error: e, stackTrace: stack);
      //await _updatePrintStatus(printedPhotoCardId, PrintedStatus.failed);
      rethrow;
    }
  }

  Future<NominatedPhoto> _prepareFrontPhoto() async {
    final frontPhotoList = ref.read(frontPhotoListProvider.notifier);
    final randomPhoto = await frontPhotoList.getRandomPhoto();

    return randomPhoto;
  }

  void _validatePrintRequirements() {
    final backPhotoCardResponseInfo = ref.watch(verifyPhotoCardProvider).value;
    //final approvalInfo = ref.read(paymentResponseStateProvider);
    final printerState = ref.read(printerServiceProvider);

    if (backPhotoCardResponseInfo == null) throw Exception('No back photo card response info available');
    //if (approvalInfo == null) throw Exception('No payment approval info available');
    if (printerState.hasError) throw Exception('Printer is not ready');
  }

  Future<
      ({
        int printedPhotoCardId,
        File backPhotoFile,
      })> _createPrintJobWithEmbeddingBackImage({
    required int frontPhotoCardId,
    required int backPhotoCardId,
  }) async {
    try {
      final request = CreatePrintRequest(
        kioskMachineId: ref.read(kioskInfoServiceProvider)!.kioskMachineId,
        kioskEventId: ref.read(kioskInfoServiceProvider)!.kioskEventId,
        frontPhotoCardId: frontPhotoCardId,
        backPhotoCardId: backPhotoCardId,
      );

      final response = await ref.read(kioskRepositoryProvider).createPrintStatus(request: request);

      final backPhotoFile = await ImageHelper().convertImageUrlToFile(response.formattedImageUrl);

      return (printedPhotoCardId: response.printedPhotoCardId, backPhotoFile: backPhotoFile);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updatePrintStatus(int printedPhotoCardId, PrintedStatus status) async {
    try {
      final request = UpdatePrintRequest(
        kioskMachineId: ref.read(kioskInfoServiceProvider)!.kioskMachineId,
        kioskEventId: ref.read(kioskInfoServiceProvider)!.kioskEventId,
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
    required File frontPhoto,
    required File embedded,
  }) async {
    try {
      await ref.read(printerServiceProvider.notifier).printImage(
            frontFile: frontPhoto,
            backFile: embedded,
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

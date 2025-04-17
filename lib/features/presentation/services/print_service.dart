import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
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

    // 3. 프론트 이미지 로컬 자르기
    //todo 포토카드 편집


    // 3. 프린트 작업 생성 및 백 이미지 준비
    final printJobInfo = await _createPrintJobWithEmbeddingBackImage(
      frontPhotoCardId: frontPhotoInfo.id,
      backPhotoCardId: ref.read(verifyPhotoCardProvider).value?.backPhotoCardId ?? 0,
    );
    final localEditedFrontImage = await editImage(frontPhotoInfo.safeEmbedImage);
    // 4. 프린트 진행 및 상태 업데이트
    await _executePrintJob(
      printJobInfo.printedPhotoCardId,
      localEditedFrontImage,
      printJobInfo.backPhotoFile,
    );
  }



  Future<void> _executePrintJob(int printedPhotoCardId, File frontPhoto, File embedded) async {
    try {
      // 프린트 상태 시작
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.started);

      // 실제 프린트 실행
      await _executePrint(frontPhoto: frontPhoto, embedded: embedded);

      // 프린트 상태 완료
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.completed);
    } catch (e, stack) {
      logger.e('PrintService._executePrintJob failure', error: e, stackTrace: stack);
      await _updatePrintStatus(printedPhotoCardId, PrintedStatus.failed);
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
    final approvalInfo = ref.read(paymentResponseStateProvider);
    final printerState = ref.read(printerServiceProvider);

    if (backPhotoCardResponseInfo == null) throw Exception('No back photo card response info available');
    if (approvalInfo == null) throw Exception('No payment approval info available');
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

  Future<File> editImage(File inputFile) async {
    final bytes = await inputFile.readAsBytes();
    final original = img.decodeImage(bytes);

    if (original == null) throw Exception("이미지를 읽을 수 없습니다.");
    // 🔪 자르기: 상단 20%, 하단 20% 잘라냄
    final cropTop = (original.height * 0.2).toInt();
    final cropBottom = (original.height * 0.8).toInt();
    final cropped = img.copyCrop(original, x: 0, y: cropTop, width: original.width, height: cropBottom - cropTop);

    // 📏 원본 높이에 맞춘 캔버스
    final canvasHeight = original.height;
    final canvasWidth = cropped.width;
    final canvas = img.Image(width: canvasWidth, height: canvasHeight);

    // 🎨 분홍 배경
    final blue = img.ColorInt8.rgb(1, 1, 255); //파랑
    img.fill(canvas, color: blue);

    // 🎯 중앙 배치
    final dstY = ((canvasHeight - cropped.height) / 2).toInt();
    final dstX = 0;

    for (int y = 0; y < cropped.height; y++) {
      for (int x = 0; x < cropped.width; x++) {
        final pixel = cropped.getPixel(x, y);
        canvas.setPixel(dstX + x, dstY + y, pixel);
      }
    }
    //img.drawImage(canvas, cropped, dstY: 50);
    
    // 📝 텍스트 추가
    //img.drawStringCentered(canvas, img.arial_24, "🌸 상단 문구", y: 20);
    //img.drawStringCentered(canvas, img.arial_24, "하단 문구 🌸", y: newHeight - 30);

    // 💾 저장
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/edited_image.png';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(img.encodePng(canvas));

    return outputFile;
  }
}

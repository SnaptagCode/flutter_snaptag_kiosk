import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio show Response;
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_process_provider.g.dart';

@riverpod
class PrintProcess extends _$PrintProcess {
  @override
  FutureOr<void> build() {
    return _startPrinting();
  }

  FutureOr<void> _startPrinting() async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      // 1. 사전 검증
      _validatePrintRequirements();

      // 2. 프론트 이미지 & 백 이미지 처리
      final frontPhotoInfo = await _prepareFrontPhoto();
      final embeddedBackImage = await _prepareBackImage();

      // 3. 프린트 작업 생성
      final printJobInfo = await _createPrintJob(
        frontPhotoCardId: frontPhotoInfo.id,
        backPhotoCardId: ref.read(verifyPhotoCardProvider).value?.backPhotoCardId ?? 0,
        file: embeddedBackImage,
      );

      try {
        await _updatePrintStatus(
          printJobInfo.printedPhotoCardId,
          PrintedStatus.started,
        );
        // 4. 실제 프린트 실행
        await _executePrint(
          frontPhotoPath: frontPhotoInfo.path,
          embedded: embeddedBackImage,
        );

        // 5. 성공 상태 업데이트
        await _updatePrintStatus(
          printJobInfo.printedPhotoCardId,
          PrintedStatus.completed,
        );
      } catch (e, stack) {
        // 프린트 실패 처리
        await _handlePrintFailure(
          printJobInfo.printedPhotoCardId,
          e,
          stack,
        );
        rethrow;
      }
    });
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
    final backPhoto = ref.read(verifyPhotoCardProvider).value;
    if (backPhoto == null) {
      throw Exception('No back photo available');
    }
    final backPhotoUrl = ref.watch(verifyPhotoCardProvider).value?.backPhotoCardOriginUrl ?? '';
    final embedConfig = ref.watch(backPhotoForPrintInfoProvider);
    final dio.Response response = await ImageHelper().getImageBytes(backPhotoUrl);
    // 1. 이미지 읽기

    // 2. Labcurity 처리
    Uint8List? processedImage = await ref.read(labcurityServiceProvider).embedImage(
          response.data,
          /**
        * LabcurityImageConfig(
        *   size: embedConfig.$a,
        *   strength: embedConfig.$a,
        *   alphaCode: embedConfig.$a,
        *   bravoCode: embedConfig.$a,
        *   charlieCode: embedConfig.$a,
        *   deltaCode: embedConfig.$a,
        *   echoCode: embedConfig.$a,
        *   foxtrotCode: embedConfig.$a,
        * ),
       */
        );
    try {
      // 1. 이미지 다운로드
      final response = await ImageHelper().getImageBytes(backPhoto.backPhotoCardOriginUrl);

      // 2. Labcurity 처리
      final processedImage = await ref.read(labcurityServiceProvider).embedImage(
            response.data,
          );

      if (processedImage == null) {
        throw PrinterException('Failed to process back image with Labcurity');
      }

      // 3. 임시 파일로 저장
      final tempFile = File('${DateTime.now().millisecondsSinceEpoch}_processed.png');
      await tempFile.writeAsBytes(processedImage);

      return tempFile;
    } catch (e) {
      throw PrinterException('Failed to prepare back image: ${e.toString()}');
    }
  }

  Future<void> _handlePrintFailure(
    int printedPhotoCardId,
    Object error,
    StackTrace stack,
  ) async {
    logger.e('Print failure', error: error, stackTrace: stack);

    try {
      // 1. 프린트 상태 실패로 업데이트
      await _updatePrintStatus(
        printedPhotoCardId,
        PrintedStatus.failed,
      );

      // 2. 결제 환불 시도
      await ref.read(userOrderProcessProvider.notifier).startRefund();
    } catch (refundError, refundStack) {
      logger.e(
        'Failed to handle print failure properly',
        error: refundError,
        stackTrace: refundStack,
      );
      // 결제 환불 실패 - 관리자의 수동 개입이 필요할 수 있음
      throw Exception('Failed to process refund after print failure');
    }
  }

  void _validatePrintRequirements() {
    // backPhotoForPrintInfo 검증
    final backPhotoForPrintInfo = ref.read(backPhotoForPrintInfoProvider);
    if (backPhotoForPrintInfo == null) {
      throw Exception('No back photo for print info available');
    }
    // backPhotoCardResponseInfo 검증
    final backPhotoCardResponseInfo = ref.watch(verifyPhotoCardProvider).value;

    if (backPhotoCardResponseInfo == null) {
      throw Exception('No back photo card response info available');
    }
    // 결제 정보 검증
    final approvalInfo = ref.read(approvalInfoProvider);
    if (approvalInfo == null) {
      throw Exception('No payment approval info available');
    }
    // 프린터 상태 검증
    final printerState = ref.read(printerStateProvider);
    if (printerState.hasError) {
      throw Exception('Printer is not ready');
    }
  }

  Future<void> _executePrint({required String frontPhotoPath, required File embedded}) async {
    final printerState = ref.read(printerStateProvider.notifier);

    try {
      // 2. 프린트 실행
      await printerState.printImage(
        frontImagePath: frontPhotoPath,
        embeddedFile: embedded,
      );
    } catch (e) {
      throw Exception();
    } finally {
      // 임베딩 파일 삭제
      if (await embedded.exists()) {
        await embedded.delete();
      }
    }
  }

  Future<({int printedPhotoCardId})> _createPrintJob(
      {required int frontPhotoCardId, required int backPhotoCardId, required File file}) async {
    try {
      final request = PostPrintRequest(
        kioskMachineId: ref.watch(storageServiceProvider).settings.kioskMachineId,
        kioskEventId: ref.watch(storageServiceProvider).settings.kioskEventId,
        frontPhotoCardId: frontPhotoCardId,
        backPhotoCardId: backPhotoCardId,
        file: file,
      );

      final response = await ref.read(kioskRepositoryProvider).createPrintedStatus(request: request);
      return (printedPhotoCardId: response.printedPhotoCardId);
    } catch (e) {
      throw Exception('Failed to create print job');
    }
  }

  Future<void> _updatePrintStatus(int printedPhotoCardId, PrintedStatus status) async {
    try {
      final request = PatchPrintRequest(
        kioskMachineId: ref.watch(storageServiceProvider).settings.kioskMachineId,
        kioskEventId: ref.watch(storageServiceProvider).settings.kioskEventId,
        status: status,
      );

      await ref
          .read(kioskRepositoryProvider)
          .updatePrintedStatus(printedPhotoCardId: printedPhotoCardId, request: request);
    } catch (e) {
      throw Exception('Failed to update print status');
    }
  }
}

class PrinterException implements Exception {
  final String message;
  final int? errorCode;

  PrinterException(this.message, {this.errorCode});

  @override
  String toString() => 'PrinterException: $message${errorCode != null ? ' (Error code: $errorCode)' : ''}';
}

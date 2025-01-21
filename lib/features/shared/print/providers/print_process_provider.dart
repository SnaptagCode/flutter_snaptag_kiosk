import 'dart:io';

import 'package:dio/dio.dart' as dio show Dio, Options, ResponseType, Response;
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_process_provider.g.dart';

@riverpod
class PrintProcess extends _$PrintProcess {
  @override
  AsyncValue<void> build() {
    _startPrinting();
    return const AsyncValue.data(null);
  }

  Future<void> _startPrinting() async {
    state = const AsyncValue.loading();

    try {
      // 1. 사전 검증
      _validatePrintRequirements();

      // 2. 프린트 작업 생성
      await _createPrintJob();

      // 3. BackPhoto 이미지 임베딩

      final File embedBackImage = await _embeddingProcess();

      // 4. 프린트 실행
      await _executePrint(embedBackImage);

      // 5. 상태 업데이트
      await _updatePrintStatus(PrintedStatus.completed);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      await _handlePrintFailure(e, stack);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<File> _embeddingProcess() async {
    final backPhotoUrl = ref.read(backPhotoCardResponseInfoProvider).backPhotoCardOriginUrl;
    final embedConfig = ref.read(backPhotoForPrintInfoProvider);
    final dio.Response response = await ImageHelper().getImageBytes(backPhotoUrl);
    // 1. 이미지 읽기

    // 2. Labcurity 처리
    final labcurityImage = ref.read(labcurityImageProvider.notifier);
    await labcurityImage.embedImage(
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
    final processedImage = await ref.read(labcurityImageProvider.future);

    if (processedImage == null) {
      throw Exception('Failed to process image with Labcurity');
    }

    // 3. 임시 파일로 저장
    final tempFile = File('${DateTime.now().millisecondsSinceEpoch}_processed.png');
    //tempFile의 Path
    logger.d('tempFile Path: ${tempFile.path}');
    await tempFile.writeAsBytes(processedImage);

    return tempFile;
  }

  void _validatePrintRequirements() {
    // backPhotoForPrintInfo 검증
    final backPhotoForPrintInfo = ref.read(backPhotoForPrintInfoProvider);
    if (backPhotoForPrintInfo == null) {
      throw Exception('No back photo for print info available');
    }
    // backPhotoCardResponseInfo 검증
    final backPhotoCardResponseInfo = ref.read(backPhotoCardResponseInfoProvider);
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

  Future<void> _executePrint(File embedded) async {
    final frontPhotoList = ref.read(frontPhotoListProvider.notifier);
    final printerState = ref.read(printerStateProvider.notifier);
    final backPhoto = ref.read(backPhotoForPrintInfoProvider);

    try {
      // 1. 랜덤 프론트 이미지 선택
      final randomPhoto = await frontPhotoList.getRandomPhoto();

      // 2. 프린트 실행
      await printerState.printImage(
        frontImagePath: randomPhoto.path,
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

  Future<void> _createPrintJob() async {
    /**
    try {
      final request = PostPrintRequest();

      await ref.read(kioskRepositoryProvider).createPrintedStatus(request: request);
    } catch (e) {
      throw Exception('Failed to create print job');
    }
     */
  }

  Future<void> _updatePrintStatus(PrintedStatus status) async {
    /**
    try {
      final request = PatchPrintRequest();

      await ref.read(kioskRepositoryProvider).updatePrintedStatus(request: request);
    } catch (e) {
      throw Exception('Failed to update print status');
    }
    */
  }

  Future<void> _handlePrintFailure(Object error, StackTrace stack) async {
    try {
      // 1. 프린트 실패 상태 업데이트
      await _updatePrintStatus(PrintedStatus.failed);

      // 2. 결제 취소 진행
      try {
        await ref.read(paymentServiceProvider.notifier).cancelPayment();
        await ref.read(paymentServiceProvider.notifier).updateOrder(OrderStatus.refunded);
      } catch (cancelError) {
        // 결제 취소 실패 시
        await ref.read(paymentServiceProvider.notifier).updateOrder(OrderStatus.refunded_failed);
        throw Exception('Payment cancellation failed');
      }
    } catch (e) {
      throw Exception('Failed to handle print failure');
    }
  }
}

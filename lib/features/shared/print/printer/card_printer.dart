import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:io';

import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'printer_bindings.dart';

part 'card_printer.g.dart';

enum PrinterStatus { ready, busy, error }

@riverpod
class PrinterState extends _$PrinterState {
  late final PrinterBindings _bindings;

  @override
  FutureOr<PrinterStatus> build() async {
    _bindings = PrinterBindings();
    await _initializePrinter();
    return PrinterStatus.ready;
  }

  Future<void> _initializePrinter() async {
    final result = _bindings.initLibrary();
    if (result != 0) {
      final error = _bindings.getErrorInfo(result);
      throw Exception('Printer initialization failed: $error');
    }
    _bindings.initializeUsb(); // USB 초기화 추가
  }

  Future<void> printImage({
    required String frontImagePath,
    required String backImagePath,
  }) async {
    try {
      state = const AsyncValue.loading();

      // 1. 카드 위치 확인
      final hasCard = _bindings.checkCardPosition();
      if (hasCard) {
        _bindings.ejectCard();
      }

      // 2. 후면 이미지 로드 및 회전
      final rearImage = await File(backImagePath).readAsBytes();
      final rotatedRearImage = _bindings.flipImage180(rearImage);

      // 임시 파일로 저장
      final rotatedRearPath = '${backImagePath}_rotated.png';
      await File(rotatedRearPath).writeAsBytes(rotatedRearImage);

      try {
        // 3. 앞면 캔버스 준비 및 그리기
        final frontBuffer = StringBuffer();
        await _prepareAndDrawImage(frontBuffer, frontImagePath, true);

        // 4. 후면 캔버스 준비 및 그리기
        final rearBuffer = StringBuffer();
        await _prepareAndDrawImage(rearBuffer, rotatedRearPath, false);

        // 5. 카드 투입
        _bindings.injectCard();

        // 6. 인쇄
        _bindings.printCard(
          frontImageInfo: frontBuffer.toString(),
          backImageInfo: rearBuffer.toString(),
        );

        // 7. 카드 배출
        _bindings.ejectCard();
      } finally {
        // 회전된 이미지 임시 파일 삭제
        await File(rotatedRearPath).delete().catchError((_) {});
      }

      state = const AsyncValue.data(PrinterStatus.ready);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 프린터 상태 모니터링 메서드 추가
  Future<void> monitorPrinterStatus() async {
    while (state is AsyncData) {
      final status = _bindings.getPrinterStatus();
      if (status != null) {
        if (status.errorStatus != 0) {
          state = AsyncError('Printer error: ${status.errorStatus}', StackTrace.current);
          break;
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // URL로부터 이미지 다운로드
  Future<File> _downloadImage(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image from $url');
    }

    // 임시 디렉토리에 저장
    final tempDir = Directory.systemTemp;
    final file = File(path.join(tempDir.path, filename));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  // URL 이미지 프린트
  Future<void> printImageFromUrl({
    required String frontImageUrl,
    required String rearImageUrl,
  }) async {
    try {
      state = const AsyncValue.loading();

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final frontFile = await _downloadImage(frontImageUrl, 'temp_front_$timestamp.png');
      final rearFile = await _downloadImage(rearImageUrl, 'temp_rear_$timestamp.png');

      try {
        final frontImage = await frontFile.readAsBytes();
        final rearImage = await rearFile.readAsBytes();

        // 카드 위치 확인 및 배출
        final hasCard = _bindings.checkCardPosition();
        if (hasCard) {
          _bindings.ejectCard();
        }

        // 앞면 캔버스 준비 및 이미지 그리기
        final frontBuffer = StringBuffer();
        await _prepareAndDrawImage(frontBuffer, frontFile.path, true);

        // 후면 이미지 회전 및 저장
        final rotatedRearImage = _bindings.flipImage180(rearImage);
        final rotatedRearFile = File('${rearFile.path}_rotated');
        await rotatedRearFile.writeAsBytes(rotatedRearImage);

        // 후면 캔버스 준비 및 이미지 그리기
        final rearBuffer = StringBuffer();
        await _prepareAndDrawImage(rearBuffer, rotatedRearFile.path, false);

        // 카드 투입
        _bindings.injectCard();

        // 인쇄
        _bindings.printCard(
          frontImageInfo: frontBuffer.toString(),
          backImageInfo: rearBuffer.toString(),
        );

        // 카드 배출
        _bindings.ejectCard();
      } finally {
        // 임시 파일 정리
        await Future.wait([
          frontFile.delete(),
          rearFile.delete(),
          File('${rearFile.path}_rotated').delete(),
        ].map((future) => future.catchError((_) {})));
      }

      state = const AsyncValue.data(PrinterStatus.ready);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _prepareAndDrawImage(StringBuffer buffer, String imagePath, bool isFront) async {
    _bindings.setCanvasOrientation(true);
    _bindings.setCoatingRegion(
      x: -1,
      y: -1,
      width: 56.0,
      height: 88.0,
      isFront: isFront,
      isErase: false,
    );
    _bindings.setImageParameters(
      transparency: 1,
      rotation: 0,
      scale: 0,
    );

    _bindings.prepareCanvas(isColor: true);

    _bindings.drawImage(
      imagePath: imagePath,
      x: -1,
      y: -1,
      width: 56.0,
      height: 88.0,
      noAbsoluteBlack: true,
    );

    buffer.write(_commitCanvas());
  }

  String _commitCanvas() {
    final strPtr = calloc<ffi.Uint8>(200).cast<Utf8>();
    final lenPtr = calloc<ffi.Int32>()..value = 200;

    try {
      final result = _bindings.commitCanvas(strPtr, lenPtr);
      if (result != 0) {
        throw Exception('Failed to commit canvas');
      }
      return strPtr.toDartString();
    } finally {
      calloc.free(strPtr);
      calloc.free(lenPtr);
    }
  }
}

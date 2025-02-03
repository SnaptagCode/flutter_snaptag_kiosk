import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:image/image.dart' as img;

// DLL 함수 시그니처 정의
typedef R600LibInitNative = Uint32 Function();
typedef R600LibInit = int Function();

typedef R600GetErrorOuterInfoNative = Uint32 Function(Uint32 errCode, Pointer<Utf8> outputStr, Pointer<Int32> len);
typedef R600GetErrorOuterInfo = int Function(int errCode, Pointer<Utf8> outputStr, Pointer<Int32> len);

// 추가적인 DLL 함수 시그니처 정의
typedef R600IsPrtHaveCardNative = Uint32 Function(Pointer<Uint8> flag);
typedef R600IsPrtHaveCard = int Function(Pointer<Uint8> flag);

typedef R600PrepareCanvasNative = Uint32 Function(Int32 nChromaticMode, Int32 nMonoChroMode);
typedef R600PrepareCanvas = int Function(int nChromaticMode, int nMonoChroMode);

typedef R600DrawTextNative = Uint32 Function(
    Double dX, Double dY, Double width, Double height, Pointer<Utf8> szText, Int32 nSetNoAbsoluteBlack);
typedef R600DrawText = int Function(
    double dX, double dY, double width, double height, Pointer<Utf8> szText, int nSetNoAbsoluteBlack);

typedef R600CardInjectNative = Uint32 Function(Uint8 ucDestPos);
typedef R600CardInject = int Function(int ucDestPos);

typedef R600PrintDrawNative = Uint32 Function(Pointer<Utf8> szImgInfoFront, Pointer<Utf8> szImgInfoBack);
typedef R600PrintDraw = int Function(Pointer<Utf8> szImgInfoFront, Pointer<Utf8> szImgInfoBack);

typedef R600CardEjectNative = Uint32 Function(Uint8 ucDestPos);
typedef R600CardEject = int Function(int ucDestPos);

// 추가적인 DLL 함수 시그니처 정의
typedef R600EnumUsbPrtNative = Uint32 Function(Pointer<Uint8> enumList, Pointer<Uint32> listLen, Pointer<Int32> num);
typedef R600EnumUsbPrt = int Function(Pointer<Uint8> enumList, Pointer<Uint32> listLen, Pointer<Int32> num);

typedef R600UsbSetTimeoutNative = Uint32 Function(Uint32 readTimeout, Uint32 writeTimeout);
typedef R600UsbSetTimeout = int Function(int readTimeout, int writeTimeout);

// 추가되어야 할 함수 시그니처 정의 (기존 typedef 선언부 아래)
typedef R600SetCanvasPortraitNative = Uint32 Function(Int32);
typedef R600SetCanvasPortrait = int Function(int nPortrait);

typedef R600SetCoatRgnNative = Uint32 Function(Double, Double, Double, Double, Uint8, Uint8);
typedef R600SetCoatRgn = int Function(double x, double y, double width, double height, int isFront, int isMeansErase);

typedef R600SetImageParaNative = Uint32 Function(Int32, Int32, Float);
typedef R600SetImagePara = int Function(int whiteTransparency, int nRotation, double fScale);
// commitCanvas를 위한 typedef 추가
typedef R600CommitCanvasNative = Uint32 Function(
  Pointer<Utf8> szImgInfo,
  Pointer<Int32> pImgInfoLen,
);
typedef R600CommitCanvas = int Function(
  Pointer<Utf8> szImgInfo,
  Pointer<Int32> pImgInfoLen,
);

typedef R600QueryPrtStatusNative = Uint32 Function(
  Pointer<Int16> pChassisTemp,
  Pointer<Int16> pPrintheadTemp,
  Pointer<Int16> pHeaterTemp,
  Pointer<Uint32> pMainStatus,
  Pointer<Uint32> pSubStatus,
  Pointer<Uint32> pErrorStatus,
  Pointer<Uint32> pWarningStatus,
  Pointer<Uint8> pMainCode,
  Pointer<Uint8> pSubCode,
);

typedef R600QueryPrtStatus = int Function(
  Pointer<Int16> pChassisTemp,
  Pointer<Int16> pPrintheadTemp,
  Pointer<Int16> pHeaterTemp,
  Pointer<Uint32> pMainStatus,
  Pointer<Uint32> pSubStatus,
  Pointer<Uint32> pErrorStatus,
  Pointer<Uint32> pWarningStatus,
  Pointer<Uint8> pMainCode,
  Pointer<Uint8> pSubCode,
);

// 추가적인 DLL 함수 시그니처 정의
typedef R600SelectPrtNative = Uint32 Function(Pointer<Uint8> enumList);
typedef R600SelectPrt = int Function(Pointer<Uint8> enumList);

typedef R600LibClearNative = Uint32 Function();
typedef R600LibClear = int Function();

typedef R600SetRibbonOptNative = Uint32 Function(
  Uint8 isWrite,
  Uint32 key,
  Pointer<Utf8> value,
  Int32 valueLen,
);
typedef R600SetRibbonOpt = int Function(
  int isWrite,
  int key,
  Pointer<Utf8> value,
  int valueLen,
);

typedef R600DrawWaterMarkNative = Uint32 Function(
    Double dX, Double dY, Double width, Double height, Pointer<Utf8> szImgFilePath);
typedef R600DrawWaterMark = int Function(
    double dX, double dY, double width, double height, Pointer<Utf8> szImgFilePath);

typedef R600SetFontNative = Uint32 Function(Pointer<Utf8>, Float);
typedef R600SetFont = int Function(Pointer<Utf8>, double);

typedef R600SetTextIsStrongNative = Uint32 Function(Int32);
typedef R600SetTextIsStrong = int Function(int);

typedef R600DrawImageNative = Uint32 Function(
    Double dX, Double dY, Double dWidth, Double dHeight, Pointer<Utf8> szImgFilePath, Int32 nSetNoAbsoluteBlack);
typedef R600DrawImage = int Function(
    double dX, double dY, double dWidth, double dHeight, Pointer<Utf8> szImgFilePath, int nSetNoAbsoluteBlack);

// 상태값을 담을 클래스 추가
class _PrinterStatus {
  final int mainCode;
  final int subCode;
  final int mainStatus;
  final int errorStatus;
  final int warningStatus;
  final int chassisTemperature;
  final int printHeadTemperature;
  final int heaterTemperature;
  final int subStatus;

  const _PrinterStatus({
    required this.mainCode,
    required this.subCode,
    required this.mainStatus,
    required this.errorStatus,
    required this.warningStatus,
    required this.chassisTemperature,
    required this.printHeadTemperature,
    required this.heaterTemperature,
    required this.subStatus,
  });
}

class PrinterBindings {
  late final DynamicLibrary _dll;
  late final R600LibInit _libInit;
  late final R600GetErrorOuterInfo _getErrorInfo;
  late final R600IsPrtHaveCard _isPrtHaveCard;
  late final R600PrepareCanvas _prepareCanvas;
  late final R600DrawText _drawText;
  late final R600CardInject _cardInject;
  late final R600PrintDraw _printDraw;
  late final R600CardEject _cardEject;
  late final R600SetCanvasPortrait _setCanvasPortrait;
  late final R600SetCoatRgn _setCoatRgn;
  late final R600SetImagePara _setImagePara;
  late final R600QueryPrtStatus _queryPrinterStatus;
  late final R600EnumUsbPrt _enumUsbPrt;
  late final R600UsbSetTimeout _usbSetTimeout;
  late final R600CommitCanvas _commitCanvas;
  late final R600SelectPrt _selectPrinter; // 추가
  late final R600LibClear _libClear;
  late final R600SetRibbonOpt _setRibbonOpt;
  late final R600DrawWaterMark _drawWaterMark;
  late final R600SetFont _setFont;
  late final R600SetTextIsStrong _setTextIsStrong;
  late final R600DrawImage _drawImage;

  PrinterBindings() {
    // DLL 로드
    _dll = DynamicLibrary.open(FilePaths.printerDLL.buildPath);

    // 함수 바인딩
    _libInit = _dll.lookupFunction<R600LibInitNative, R600LibInit>('R600LibInit');
    _getErrorInfo = _dll.lookupFunction<R600GetErrorOuterInfoNative, R600GetErrorOuterInfo>('R600GetErrorOuterInfo');

    // 추가 함수 바인딩
    _isPrtHaveCard = _dll.lookupFunction<R600IsPrtHaveCardNative, R600IsPrtHaveCard>('R600IsPrtHaveCard');
    _prepareCanvas = _dll.lookupFunction<R600PrepareCanvasNative, R600PrepareCanvas>('R600PrepareCanvas');
    _drawImage = _dll.lookupFunction<R600DrawImageNative, R600DrawImage>('R600DrawImage');
    _drawText = _dll.lookupFunction<R600DrawTextNative, R600DrawText>('R600DrawText');
    _cardInject = _dll.lookupFunction<R600CardInjectNative, R600CardInject>('R600CardInject');
    _printDraw = _dll.lookupFunction<R600PrintDrawNative, R600PrintDraw>('R600PrintDraw');
    _cardEject = _dll.lookupFunction<R600CardEjectNative, R600CardEject>('R600CardEject');
    _setCanvasPortrait =
        _dll.lookupFunction<R600SetCanvasPortraitNative, R600SetCanvasPortrait>('R600SetCanvasPortrait');
    _setCoatRgn = _dll.lookupFunction<R600SetCoatRgnNative, R600SetCoatRgn>('R600SetCoatRgn');
    _setImagePara = _dll.lookupFunction<R600SetImageParaNative, R600SetImagePara>('R600SetImagePara');
    _queryPrinterStatus = _dll.lookupFunction<R600QueryPrtStatusNative, R600QueryPrtStatus>('R600QueryPrtStatus');

    // 추가 바인딩
    _enumUsbPrt = _dll.lookupFunction<R600EnumUsbPrtNative, R600EnumUsbPrt>('R600EnumUsbPrt');
    _usbSetTimeout = _dll.lookupFunction<R600UsbSetTimeoutNative, R600UsbSetTimeout>('R600UsbSetTimeout');
    _commitCanvas = _dll.lookupFunction<R600CommitCanvasNative, R600CommitCanvas>('R600CommitCanvas');
    _selectPrinter = _dll.lookupFunction<R600SelectPrtNative, R600SelectPrt>('R600SelectPrt');
    _libClear = _dll.lookupFunction<R600LibClearNative, R600LibClear>('R600LibClear');
    _setRibbonOpt = _dll.lookupFunction<R600SetRibbonOptNative, R600SetRibbonOpt>('R600SetRibbonOpt');
    _drawWaterMark = _dll.lookupFunction<R600DrawWaterMarkNative, R600DrawWaterMark>('R600DrawWaterMark');
    _setFont = _dll.lookupFunction<R600SetFontNative, R600SetFont>('R600SetFont');
    _setTextIsStrong = _dll.lookupFunction<R600SetTextIsStrongNative, R600SetTextIsStrong>('R600SetTextIsStrong');
  }

  int initLibrary() {
    return _libInit();
  }

  String getErrorInfo(int errorCode) {
    final outputStr = calloc<Uint8>(500).cast<Utf8>();
    final len = calloc<Int32>();
    len.value = 500;

    try {
      final result = _getErrorInfo(errorCode, outputStr, len);
      if (result != 0) return 'Failed to get error info';
      return outputStr.toDartString();
    } finally {
      calloc.free(outputStr);
      calloc.free(len);
    }
  }

  // 카드 위치 확인 함수
  bool checkCardPosition() {
    final flag = calloc<Uint8>();
    try {
      final result = _isPrtHaveCard(flag);
      if (result != 0) {
        throw Exception('Failed to check card position');
      }
      return flag.value != 0;
    } finally {
      calloc.free(flag);
    }
  }

  // 캔버스 준비 함수
  void prepareCanvas({bool isColor = true}) {
    logger.d('PrepareCanvas called with isColor: $isColor');
    // 첫 번째 파라미터: chromatic mode (0: monochrome, 1: color)
    // 두 번째 파라미터: monochrome mode (0: default)
    final result = _prepareCanvas(isColor ? 0 : 1, 0);
    logger.d('PrepareCanvas result: $result');

    if (result != 0) {
      final error = getErrorInfo(result);
      throw Exception('Failed to prepare canvas: $error (code: $result)');
    }
  }

  // 이미지 그리기 함수
  void drawImage({
    required String imagePath,
    required double x,
    required double y,
    required double width,
    required double height,
    bool noAbsoluteBlack = true,
  }) {
    logger.d('Drawing image from path: $imagePath'); // 경로 확인
    logger.d('Image file exists: ${File(imagePath).existsSync()}'); // 파일 존재 확인

    final pathPointer = imagePath.toNativeUtf8();
    try {
      final result = _drawImage(x, y, width, height, pathPointer.cast(), noAbsoluteBlack ? 1 : 0);
      logger.d('DrawImage result: $result'); // 결과 코드 확인
      if (result != 0) {
        final error = getErrorInfo(result);
        throw Exception('Failed to draw image: $error (code: $result)');
      }
    } finally {
      calloc.free(pathPointer);
    }
  }

  // 텍스트 그리기 함수
  void drawText({
    required String text,
    required double x,
    required double y,
    required double width,
    required double height,
    bool noAbsoluteBlack = true,
  }) {
    final textPointer = text.toNativeUtf8();
    try {
      final result = _drawText(x, y, width, height, textPointer.cast(), noAbsoluteBlack ? 1 : 0);
      if (result != 0) {
        throw Exception('Failed to draw text');
      }
    } finally {
      calloc.free(textPointer);
    }
  }

  // 카드 투입 함수
  void injectCard() {
    final result = _cardInject(0); // 0: 기본 위치
    if (result != 0) {
      throw Exception('Failed to inject card');
    }
  }

  // 인쇄 함수
  void printCard({
    required String frontImageInfo,
    String? backImageInfo,
  }) {
    final frontPointer = frontImageInfo.toNativeUtf8();
    final backPointer = backImageInfo?.toNativeUtf8() ?? nullptr;
    try {
      final result = _printDraw(frontPointer, backPointer);
      if (result != 0) {
        throw Exception('Failed to print card');
      }
    } finally {
      calloc.free(frontPointer);
      if (backImageInfo != null) {
        calloc.free(backPointer);
      }
    }
  }

  // 카드 배출 함수
  void ejectCard() {
    final result = _cardEject(0); // 0: 왼쪽으로 배출
    if (result != 0) {
      throw Exception('Failed to eject card');
    }
  }

  void setCanvasOrientation(bool isPortrait) {
    final result = _setCanvasPortrait(isPortrait ? 1 : 0);
    if (result != 0) {
      throw Exception('Failed to set canvas orientation');
    }
  }

  void setCoatingRegion({
    required double x,
    required double y,
    required double width,
    required double height,
    required bool isFront,
    required bool isErase,
  }) {
    final result = _setCoatRgn(x, y, width, height, isFront ? 1 : 0, isErase ? 1 : 0);
    if (result != 0) {
      throw Exception('Failed to set coating region');
    }
  }

  void setImageParameters({
    required int transparency,
    required int rotation,
    required double scale,
  }) {
    final result = _setImagePara(transparency, rotation, scale);
    if (result != 0) {
      throw Exception('Failed to set image parameters');
    }
  }

  // getPrinterStatus 메서드 추가
  _PrinterStatus? getPrinterStatus() {
    final pChassisTemp = calloc<Int16>();
    final pPrintheadTemp = calloc<Int16>();
    final pHeaterTemp = calloc<Int16>();
    final pMainStatus = calloc<Uint32>();
    final pSubStatus = calloc<Uint32>();
    final pErrorStatus = calloc<Uint32>();
    final pWarningStatus = calloc<Uint32>();
    final pMainCode = calloc<Uint8>();
    final pSubCode = calloc<Uint8>();

    try {
      final result = _queryPrinterStatus(
        pChassisTemp,
        pPrintheadTemp,
        pHeaterTemp,
        pMainStatus,
        pSubStatus,
        pErrorStatus,
        pWarningStatus,
        pMainCode,
        pSubCode,
      );

      if (result != 0) {
        logger.d('Query printer status failed with code: $result'); // 디버그용
        return null; // null 반환으로 변경
      }

      return _PrinterStatus(
        mainCode: pMainCode.value,
        subCode: pSubCode.value,
        mainStatus: pMainStatus.value,
        errorStatus: pErrorStatus.value,
        warningStatus: pWarningStatus.value,
        chassisTemperature: pChassisTemp.value,
        printHeadTemperature: pPrintheadTemp.value,
        heaterTemperature: pHeaterTemp.value,
        subStatus: pSubStatus.value,
      );
    } catch (e) {
      logger.d('Error in getPrinterStatus: $e'); // 디버그용
      return null; // 예외 발생 시 null 반환
    } finally {
      calloc.free(pChassisTemp);
      calloc.free(pPrintheadTemp);
      calloc.free(pHeaterTemp);
      calloc.free(pMainStatus);
      calloc.free(pSubStatus);
      calloc.free(pErrorStatus);
      calloc.free(pWarningStatus);
      calloc.free(pMainCode);
      calloc.free(pSubCode);
    }
  }

  // USB 초기화 메서드 추가
  void initializeUsb() {
    final enumListPtr = calloc<Uint8>(500);
    final listLenPtr = calloc<Uint32>()..value = 500;
    final numPtr = calloc<Int32>()..value = 10;

    try {
      // USB 프린터 열거
      final enumResult = _enumUsbPrt(enumListPtr.cast(), listLenPtr, numPtr);
      if (enumResult != 0) {
        throw Exception('Failed to enumerate USB printer');
      }

      // USB 시간 초과 설정
      final timeoutResult = _usbSetTimeout(3000, 3000);
      if (timeoutResult != 0) {
        throw Exception('Failed to set USB timeout');
      }

      // 프린터 선택
      final selectResult = _selectPrinter(enumListPtr.cast());
      if (selectResult != 0) {
        throw Exception('Failed to select printer');
      }
    } finally {
      calloc.free(enumListPtr);
      calloc.free(listLenPtr);
      calloc.free(numPtr);
    }
  }

  // 이미지 회전 기능 추가
  Uint8List flipImage180(Uint8List imageBytes) {
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage != null) {
      final flippedImage = img.copyRotate(originalImage, angle: 180);
      return Uint8List.fromList(img.encodePng(flippedImage));
    }
    return imageBytes;
  }

  // commitCanvas 메서드 추가
  int commitCanvas(Pointer<Utf8> strPtr, Pointer<Int32> lenPtr) {
    final result = _commitCanvas(strPtr, lenPtr);
    return result;
  }

  bool connectPrinter({bool isEtherNet = false}) {
    final enumListPtr = calloc<Uint8>(500);
    final listLenPtr = calloc<Uint32>()..value = 500;
    final numPtr = calloc<Int32>()..value = 10;

    try {
      // 먼저 이전 상태를 정리
      _libInit();

      logger.d('Enumerating USB printer...'); // 디버그 로그 추가
      // USB 프린터만 사용
      int result = _enumUsbPrt(enumListPtr.cast(), listLenPtr, numPtr);
      if (result != 0) {
        logger.d('Failed to enumerate printer: $result');
        return false;
      }

      logger.d('Setting USB timeout...'); // 디버그 로그 추가
      result = _usbSetTimeout(3000, 3000);
      if (result != 0) {
        logger.d('Failed to set USB timeout: $result');
        return false;
      }

      logger.d('Selecting printer...'); // 디버그 로그 추가
      result = _selectPrinter(enumListPtr.cast());
      if (result != 0) {
        logger.d('Failed to select printer: $result');
        return false;
      }

      logger.d('Printer connected successfully'); // 디버그 로그 추가
      return true;
    } finally {
      calloc.free(enumListPtr);
      calloc.free(listLenPtr);
      calloc.free(numPtr);
    }
  }

  bool ensurePrinterReady() {
    try {
      // 카드 존재 여부 확인
      final flag = calloc<Uint8>();
      try {
        int result = _isPrtHaveCard(flag);
        if (result != 0) {
          logger.d('Failed to check card position');
          return false;
        }

        // 카드가 있다면 배출
        if (flag.value != 0) {
          logger.d('Card is in the printer, ejecting...');
          result = _cardEject(0); // 왼쪽으로 배출
          if (result != 0) {
            logger.d('Failed to eject card');
            return false;
          }
        }
        return true;
      } finally {
        calloc.free(flag);
      }
    } catch (e) {
      logger.d('Error in ensurePrinterReady: $e');
      return false;
    }
  }

  void clearLibrary() {
    _libClear();
  }

  void setRibbonOpt(
    int isWrite,
    int key,
    String value,
    int valueLen,
  ) {
    final valuePtr = value.toNativeUtf8();
    try {
      final result = _setRibbonOpt(isWrite, key, valuePtr, valueLen);
      if (result != 0) {
        throw Exception('Failed to set ribbon opt');
      }
    } finally {
      calloc.free(valuePtr);
    }
  }

  void drawWaterMark(String imagePath) {
    final imagePathPtr = imagePath.toNativeUtf8();
    try {
      final result = _drawWaterMark(0, 0, 0, 0, imagePathPtr);
      if (result != 0) {
        throw Exception('Failed to draw water mark');
      }
    } finally {
      calloc.free(imagePathPtr);
    }
  }

  void setFont(String fontName, double fontSize) {
    final fontNamePtr = fontName.toNativeUtf8();
    try {
      final result = _setFont(fontNamePtr, fontSize);
      if (result != 0) {
        throw Exception('Failed to set font');
      }
    } finally {
      calloc.free(fontNamePtr);
    }
  }

  void setTextIsStrong(int isStrong) {
    final result = _setTextIsStrong(isStrong);
    if (result != 0) {
      throw Exception('Failed to set text strength');
    }
  }
}

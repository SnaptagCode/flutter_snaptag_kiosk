import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as img;

// DLL 함수 시그니처 정의
typedef R600LibInitNative = ffi.Uint32 Function();
typedef R600LibInit = int Function();

typedef R600GetErrorOuterInfoNative = ffi.Uint32 Function(
    ffi.Uint32 errCode, ffi.Pointer<Utf8> outputStr, ffi.Pointer<ffi.Int32> len);
typedef R600GetErrorOuterInfo = int Function(int errCode, ffi.Pointer<Utf8> outputStr, ffi.Pointer<ffi.Int32> len);

// 추가적인 DLL 함수 시그니처 정의
typedef R600IsPrtHaveCardNative = ffi.Uint32 Function(ffi.Pointer<ffi.Uint8> flag);
typedef R600IsPrtHaveCard = int Function(ffi.Pointer<ffi.Uint8> flag);

typedef R600PrepareCanvasNative = ffi.Uint32 Function(ffi.Int32 nChromaticMode, ffi.Int32 nMonoChroMode);
typedef R600PrepareCanvas = int Function(int nChromaticMode, int nMonoChroMode);

typedef R600DrawImageNative = ffi.Uint32 Function(ffi.Double dX, ffi.Double dY, ffi.Double dWidth, ffi.Double dHeight,
    ffi.Pointer<Utf8> szImgFilePath, ffi.Int32 nSetNoAbsoluteBlack);
typedef R600DrawImage = int Function(
    double dX, double dY, double dWidth, double dHeight, ffi.Pointer<Utf8> szImgFilePath, int nSetNoAbsoluteBlack);

typedef R600DrawTextNative = ffi.Uint32 Function(ffi.Double dX, ffi.Double dY, ffi.Double width, ffi.Double height,
    ffi.Pointer<Utf8> szText, ffi.Int32 nSetNoAbsoluteBlack);
typedef R600DrawText = int Function(
    double dX, double dY, double width, double height, ffi.Pointer<Utf8> szText, int nSetNoAbsoluteBlack);

typedef R600CardInjectNative = ffi.Uint32 Function(ffi.Uint8 ucDestPos);
typedef R600CardInject = int Function(int ucDestPos);

typedef R600PrintDrawNative = ffi.Uint32 Function(ffi.Pointer<Utf8> szImgInfoFront, ffi.Pointer<Utf8> szImgInfoBack);
typedef R600PrintDraw = int Function(ffi.Pointer<Utf8> szImgInfoFront, ffi.Pointer<Utf8> szImgInfoBack);

typedef R600CardEjectNative = ffi.Uint32 Function(ffi.Uint8 ucDestPos);
typedef R600CardEject = int Function(int ucDestPos);

// 추가적인 DLL 함수 시그니처 정의
typedef R600EnumUsbPrtNative = ffi.Uint32 Function(
    ffi.Pointer<ffi.Uint8> enumList, ffi.Pointer<ffi.Uint32> listLen, ffi.Pointer<ffi.Int32> num);
typedef R600EnumUsbPrt = int Function(
    ffi.Pointer<ffi.Uint8> enumList, ffi.Pointer<ffi.Uint32> listLen, ffi.Pointer<ffi.Int32> num);

typedef R600UsbSetTimeoutNative = ffi.Uint32 Function(ffi.Uint32 readTimeout, ffi.Uint32 writeTimeout);
typedef R600UsbSetTimeout = int Function(int readTimeout, int writeTimeout);

// 추가되어야 할 함수 시그니처 정의 (기존 typedef 선언부 아래)
typedef R600SetCanvasPortraitNative = ffi.Uint32 Function(ffi.Int32);
typedef R600SetCanvasPortrait = int Function(int nPortrait);

typedef R600SetCoatRgnNative = ffi.Uint32 Function(
    ffi.Double, ffi.Double, ffi.Double, ffi.Double, ffi.Uint8, ffi.Uint8);
typedef R600SetCoatRgn = int Function(double x, double y, double width, double height, int isFront, int isMeansErase);

typedef R600SetImageParaNative = ffi.Uint32 Function(ffi.Int32, ffi.Int32, ffi.Float);
typedef R600SetImagePara = int Function(int whiteTransparency, int nRotation, double fScale);
// commitCanvas를 위한 typedef 추가
typedef R600CommitCanvasNative = ffi.Uint32 Function(
  ffi.Pointer<Utf8> szImgInfo,
  ffi.Pointer<ffi.Int32> pImgInfoLen,
);
typedef R600CommitCanvas = int Function(
  ffi.Pointer<Utf8> szImgInfo,
  ffi.Pointer<ffi.Int32> pImgInfoLen,
);
// DLL 함수 시그니처 정의부에 추가
typedef R600QueryPrtStatusNative = ffi.Uint32 Function(
  ffi.Pointer<ffi.Int16> pChassisTemp,
  ffi.Pointer<ffi.Int16> pPrintheadTemp,
  ffi.Pointer<ffi.Int16> pHeaterTemp,
  ffi.Pointer<ffi.Uint32> pMainStatus,
  ffi.Pointer<ffi.Uint32> pSubStatus,
  ffi.Pointer<ffi.Uint32> pErrorStatus,
  ffi.Pointer<ffi.Uint32> pWarningStatus,
  ffi.Pointer<ffi.Uint8> pMainCode,
  ffi.Pointer<ffi.Uint8> pSubCode,
);

typedef R600QueryPrtStatus = int Function(
  ffi.Pointer<ffi.Int16> pChassisTemp,
  ffi.Pointer<ffi.Int16> pPrintheadTemp,
  ffi.Pointer<ffi.Int16> pHeaterTemp,
  ffi.Pointer<ffi.Uint32> pMainStatus,
  ffi.Pointer<ffi.Uint32> pSubStatus,
  ffi.Pointer<ffi.Uint32> pErrorStatus,
  ffi.Pointer<ffi.Uint32> pWarningStatus,
  ffi.Pointer<ffi.Uint8> pMainCode,
  ffi.Pointer<ffi.Uint8> pSubCode,
);

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
  late final ffi.DynamicLibrary _dll;
  late final R600LibInit _libInit;
  late final R600GetErrorOuterInfo _getErrorInfo;
  late final R600IsPrtHaveCard _isPrtHaveCard;
  late final R600PrepareCanvas _prepareCanvas;
  late final R600DrawImage _drawImage;
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

  PrinterBindings() {
    // DLL 로드
    _dll = ffi.DynamicLibrary.open('libDSRetransfer600App.dll');

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
    _queryPrinterStatus = _dll.lookupFunction<
        ffi.Uint32 Function(
            ffi.Pointer<ffi.Int16>,
            ffi.Pointer<ffi.Int16>,
            ffi.Pointer<ffi.Int16>,
            ffi.Pointer<ffi.Uint32>,
            ffi.Pointer<ffi.Uint32>,
            ffi.Pointer<ffi.Uint32>,
            ffi.Pointer<ffi.Uint32>,
            ffi.Pointer<ffi.Uint8>,
            ffi.Pointer<ffi.Uint8>),
        int Function(
            ffi.Pointer<ffi.Int16>,
            ffi.Pointer<ffi.Int16>,
            ffi.Pointer<ffi.Int16>,
            ffi.Pointer<ffi.Uint32>,
            ffi.Pointer<ffi.Uint32>,
            ffi.Pointer<ffi.Uint32>,
            ffi.Pointer<ffi.Uint32>,
            ffi.Pointer<ffi.Uint8>,
            ffi.Pointer<ffi.Uint8>)>('R600QueryPrtStatus');

    // 추가 바인딩
    _enumUsbPrt = _dll.lookupFunction<R600EnumUsbPrtNative, R600EnumUsbPrt>('R600EnumUsbPrt');
    _usbSetTimeout = _dll.lookupFunction<R600UsbSetTimeoutNative, R600UsbSetTimeout>('R600UsbSetTimeout');
    _commitCanvas = _dll.lookupFunction<R600CommitCanvasNative, R600CommitCanvas>('R600CommitCanvas');
  }

  int initLibrary() {
    return _libInit();
  }

  String getErrorInfo(int errorCode) {
    final outputStr = calloc<ffi.Uint8>(500).cast<Utf8>();
    final len = calloc<ffi.Int32>();
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
    final flag = calloc<ffi.Uint8>();
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
    final result = _prepareCanvas(isColor ? 1 : 0, 0);
    if (result != 0) {
      throw Exception('Failed to prepare canvas');
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
    final pathPointer = imagePath.toNativeUtf8();
    try {
      final result = _drawImage(x, y, width, height, pathPointer, noAbsoluteBlack ? 1 : 0);
      if (result != 0) {
        throw Exception('Failed to draw image');
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
      final result = _drawText(x, y, width, height, textPointer, noAbsoluteBlack ? 1 : 0);
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
    final backPointer = backImageInfo?.toNativeUtf8() ?? ffi.nullptr;
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
    final pChassisTemp = calloc<ffi.Int16>();
    final pPrintheadTemp = calloc<ffi.Int16>();
    final pHeaterTemp = calloc<ffi.Int16>();
    final pMainStatus = calloc<ffi.Uint32>();
    final pSubStatus = calloc<ffi.Uint32>();
    final pErrorStatus = calloc<ffi.Uint32>();
    final pWarningStatus = calloc<ffi.Uint32>();
    final pMainCode = calloc<ffi.Uint8>();
    final pSubCode = calloc<ffi.Uint8>();

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
        throw Exception('Failed to get printer status');
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
    final enumListPtr = calloc<ffi.Uint8>(500);
    final listLenPtr = calloc<ffi.Uint32>()..value = 500;
    final numPtr = calloc<ffi.Int32>()..value = 10;

    try {
      final enumResult = _enumUsbPrt(enumListPtr.cast(), listLenPtr, numPtr);
      if (enumResult != 0) {
        throw Exception('Failed to enumerate USB printer');
      }

      final timeoutResult = _usbSetTimeout(3000, 3000);
      if (timeoutResult != 0) {
        throw Exception('Failed to set USB timeout');
      }
    } finally {}
    calloc.free(enumListPtr);
    calloc.free(listLenPtr);
    calloc.free(numPtr);
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
  int commitCanvas(ffi.Pointer<Utf8> strPtr, ffi.Pointer<ffi.Int32> lenPtr) {
    final result = _commitCanvas(strPtr, lenPtr);
    return result;
  }
}

part of 'printer_bindings.dart';

typedef R600LibInitNative = Uint32 Function();
typedef R600LibInit = int Function();

typedef R600GetErrorOuterInfoNative = Uint32 Function(Uint32 errCode, Pointer<Utf8> outputStr, Pointer<Int32> len);
typedef R600GetErrorOuterInfo = int Function(int errCode, Pointer<Utf8> outputStr, Pointer<Int32> len);

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

typedef R600EnumUsbPrtNative = Uint32 Function(Pointer<Uint8> enumList, Pointer<Uint32> listLen, Pointer<Int32> num);
typedef R600EnumUsbPrt = int Function(Pointer<Uint8> enumList, Pointer<Uint32> listLen, Pointer<Int32> num);

typedef R600UsbSetTimeoutNative = Uint32 Function(Uint32 readTimeout, Uint32 writeTimeout);
typedef R600UsbSetTimeout = int Function(int readTimeout, int writeTimeout);

typedef R600SetCanvasPortraitNative = Uint32 Function(Int32);
typedef R600SetCanvasPortrait = int Function(int nPortrait);

typedef R600SetCoatRgnNative = Uint32 Function(Double, Double, Double, Double, Uint8, Uint8);
typedef R600SetCoatRgn = int Function(double x, double y, double width, double height, int isFront, int isMeansErase);

typedef R600SetImageParaNative = Uint32 Function(Int32, Int32, Float);
typedef R600SetImagePara = int Function(int whiteTransparency, int nRotation, double fScale);

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

typedef R600IsFeederNoEmptyNative = Uint32 Function(Pointer<Int32>);
typedef R600IsFeederNoEmpty = int Function(Pointer<Int32>);

typedef R600GetRbnAndFilmRemainingNative = Uint32 Function(Pointer<Short> pRbnRemaining, Pointer<Short> pFilmRemaining);
typedef R600GetRbnAndFilmRemaining = int Function(Pointer<Short> pRbnRemaining, Pointer<Short> pFilmRemaining);

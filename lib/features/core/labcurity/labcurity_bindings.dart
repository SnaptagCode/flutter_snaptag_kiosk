import 'dart:ffi';

import 'package:ffi/ffi.dart';

// Seed 6
/*typedef GetLabCodeImageFullWNative = Int32 Function(
  Pointer<Utf16> keyPath,
  Pointer<Utf16> inputPath,
  Pointer<Utf16> writePath,
  Int32 size,
  Int32 strength,
  Int32 alphaCode,
  Int32 bravoCode,
  Int32 charlieCode,
  Int32 deltaCode,
  Int32 echoCode,
  Uint64 foxtrotCode,
);*/

/*
typedef GetLabCodeImageFullWDart = int Function(
  Pointer<Utf16> keyPath,
  Pointer<Utf16> inputPath,
  Pointer<Utf16> writePath,
  int size,
  int strength,
  int alphaCode,
  int bravoCode,
  int charlieCode,
  int deltaCode,
  int echoCode,
  int foxtrotCode,
);
*/

// Seed 5
typedef GetLabCodeImageWNative = Int32 Function(
    Pointer<Utf16> keyPath,
    Pointer<Utf16> inputPath,
    Pointer<Utf16> writePath,
    Int32 size,
    Int32 strength,
    Uint64 foxtrotCode,
    Pointer<Utf16> settingPath
    );

typedef GetLabCodeImageWDart = int Function(
    Pointer<Utf16> keyPath,
    Pointer<Utf16> inputPath,
    Pointer<Utf16> writePath,
    int size,
    int strength,
    int foxtrotCode,
    Pointer<Utf16> settingPath
    );
import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef GetLabCodeImageFullWNative = Int32 Function(
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
);

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

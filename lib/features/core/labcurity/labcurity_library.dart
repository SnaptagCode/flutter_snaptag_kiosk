import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'labcurity_bindings.dart';

part 'labcurity_library.g.dart';

@riverpod
LabcurityLibrary labcurityLibrary(Ref ref) {
  return LabcurityLibrary();
}

class LabcurityLibrary {
  late final DynamicLibrary _dll;
  late final GetLabCodeImageFullWDart _getLabCodeImageFullW;

  LabcurityLibrary() {
    final exeDir = Directory.current;
    final dllSource = path.join(exeDir.path, 'assets', 'labcurity', 'LabCode_x64.dll');
    _dll = DynamicLibrary.open(dllSource);

    _getLabCodeImageFullW =
        _dll.lookupFunction<GetLabCodeImageFullWNative, GetLabCodeImageFullWDart>('getLabCodeImageFullW');
  }

  int getLabCodeImageFullW(
    String keyPath,
    String inputPath,
    String writePath,
    int size,
    int strength,
    int alphaCode,
    int bravoCode,
    int charlieCode,
    int deltaCode,
    int echoCode,
    int foxtrotCode,
  ) {
    final keyPathPtr = keyPath.toNativeUtf16();
    final inputPathPtr = inputPath.toNativeUtf16();
    final writePathPtr = writePath.toNativeUtf16();

    try {
      return _getLabCodeImageFullW(
        keyPathPtr,
        inputPathPtr,
        writePathPtr,
        size,
        strength,
        alphaCode,
        bravoCode,
        charlieCode,
        deltaCode,
        echoCode,
        foxtrotCode,
      );
    } finally {
      malloc.free(keyPathPtr);
      malloc.free(inputPathPtr);
      malloc.free(writePathPtr);
    }
  }
}

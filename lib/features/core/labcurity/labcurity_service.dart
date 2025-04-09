import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/constants/directory_paths.dart';
import 'package:flutter_snaptag_kiosk/domain/entities/entities.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'labcurity_library.dart';

part 'labcurity_service.g.dart';

@riverpod
LabcurityService labcurityService(Ref ref) {
  final library = ref.watch(labcurityLibraryProvider);
  return LabcurityService(library);
}

class LabcurityService {
  final LabcurityLibrary _library;

  LabcurityService(this._library);

  Future<File> embedImage(Uint8List imageBytes, [LabcurityImageConfig? config]) async {
    config ??= const LabcurityImageConfig();

    final extension = _getImageExtension(imageBytes);
    if (extension == 'unknown') {
      throw UnsupportedError('Unsupported image format');
    }

    final dateTime = DateTime.now();
    final formattedDateTime = DateFormat('yyyyMMdd_HHmmss').format(dateTime);

    final outputDirPath = DirectoryPaths.output.buildPath;
    final inputDirPath = DirectoryPaths.input.buildPath;

    await _ensureDirectoryExists(outputDirPath);
    await _ensureDirectoryExists(inputDirPath);

    final outputFilePath = path.join(outputDirPath, '$formattedDateTime.$extension');
    final inputFilePath = path.join(inputDirPath, '$formattedDateTime.$extension');
    final labcurityPath = FilePaths.labcurityKey.buildPath;
    final settingPath = FilePaths.labcuritySetting.buildPath;
    final foxtrotCode = await updateFoxtrotCode(FilePaths.labcurityCode.buildPath);

    // Seed5
    try {
      await File(inputFilePath).writeAsBytes(imageBytes);

      final result = _library.getLabCodeImageW(
        labcurityPath,
        inputFilePath,
        outputFilePath,
        config.size,
        config.strength,
        foxtrotCode,
        settingPath
      );

      if (result == 0) {
        final outputFile = File(outputFilePath);
        if (await outputFile.exists()) {
          return outputFile;
        }
      }
      throw Exception('Failed to process image. Error code: $result');
    } finally {
      await _cleanupFiles(inputFilePath);
    }

    // Seed 6
    /*try {
      await File(inputFilePath).writeAsBytes(imageBytes);

      final result = _library.getLabCodeImageFullW(
        labcurityPath,
        inputFilePath,
        outputFilePath,
        config.size,
        config.strength,
        config.alphaCode,
        config.bravoCode,
        config.charlieCode,
        config.deltaCode,
        config.echoCode,
        config.foxtrotCode,
      );

      if (result == 0) {
        final outputFile = File(outputFilePath);
        if (await outputFile.exists()) {
          return outputFile;
        }
      }
      throw Exception('Failed to process image. Error code: $result');
    } finally {
      await _cleanupFiles(inputFilePath);
    }*/
  }

  Future<void> _ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> _cleanupFiles(String filePath) async {
    final inputFile = File(filePath);
    if (await inputFile.exists()) {
      await inputFile.delete();
    }
  }

  String _getImageExtension(Uint8List bytes) {
    if (bytes.length >= 4) {
      if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
        return 'png';
      } else if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return 'jpg';
      } else if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
        return 'gif';
      } else if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
        return 'bmp';
      }
    }
    return 'unknown';
  }
  Future<int> updateFoxtrotCode(String dirPath) async {
    //final dir = await getApplicationDocumentsDirectory();

    final file = File(dirPath);

    Map<String, dynamic> data;

    if (await file.exists()) {
      // 파일이 존재하면 읽고 파싱
      final content = await file.readAsString();
      data = jsonDecode(content);

      // 기존 값 있으면 +1
      final currentValue = data['foxtrotCode'] ?? 0;
      final changeValue = currentValue + 1;
      data['foxtrotCode'] = changeValue;
      await file.writeAsString(jsonEncode(data), flush: true);
      print('foxtrotCode updated: ${data['foxtrotCode']}');
      return changeValue;
    } else {
      // 파일이 없으면 새로 만들고 5로 시작
      data = {'foxtrotCode': 5};
      await file.writeAsString(jsonEncode(data), flush: true);
      print('foxtrotCode updated: ${data['foxtrotCode']}');
      return 5;
    }
  }
}



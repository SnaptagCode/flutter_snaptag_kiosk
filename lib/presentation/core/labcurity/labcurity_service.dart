import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/constants/directory_paths.dart';
import 'package:flutter_snaptag_kiosk/core/domain/entities/entities.dart';
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

    try {
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
    }
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
}

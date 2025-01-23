import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../../domain/entities/security_image_config.dart';
import 'labcurity_library.dart';

class LabcurityService {
  final LabcurityLibrary _library;

  LabcurityService(this._library);

  Future<Uint8List?> embedImage(Uint8List imageBytes, [LabcurityImageConfig? config]) async {
    config ??= const LabcurityImageConfig();

    final extension = _getImageExtension(imageBytes);
    if (extension == 'unknown') {
      throw UnsupportedError('Unsupported image format');
    }

    final dateTime = DateTime.now();
    final formattedDateTime = DateFormat('yyyyMMdd_HHmmss').format(dateTime);
    final formattedDate = DateFormat('yyyyMMdd').format(dateTime);

    final currentDirPath = Directory.current.path;
    final embedDirPath = path.join(currentDirPath, 'embed');
    final tempDirPath = path.join(currentDirPath, 'temp', formattedDate);

    await _ensureDirectoryExists(embedDirPath);
    await _ensureDirectoryExists(tempDirPath);

    final outputFilePath = path.join(embedDirPath, '$formattedDateTime.$extension');
    final inputFilePath = path.join(tempDirPath, '${formattedDateTime}_input_image.$extension');
    final labcurityPath = path.join(Directory.current.path, 'assets', 'labcurity', 'labcurity_key.txt');

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
          return await outputFile.readAsBytes();
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

  Future<void> _cleanupFiles(String inputFilePath) async {
    final inputFile = File(inputFilePath);
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

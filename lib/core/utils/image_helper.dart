import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio show Dio, Options, ResponseType, Response;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static final ImageHelper instance = ImageHelper._internel();

  ImageHelper._internel();

  factory ImageHelper() => instance;

  Future<dio.Response> getImageBytes(String imageUrl) async {
    final response = await dio.Dio().get<List<int>>(
      imageUrl,
      options: dio.Options(responseType: dio.ResponseType.bytes),
    );

    if (response.statusCode != 200) {
      throw StorageException(
        StorageErrorType.downloadError,
        path: imageUrl,
        originalError: 'Status code: ${response.statusCode}',
      );
    }

    if (response.data != null && response.data is List<int>) {
      return response;
    } else {
      throw StorageException(
        StorageErrorType.downloadError,
      );
    }
  }

  String getFileExtensionFromUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final lastDot = path.lastIndexOf('.');
    if (lastDot != -1) {
      return path.substring(lastDot);
    }
    return '.png'; // 기본값
  }

  String getFileExtensionFromContentType(String? contentType) {
    logger.i('Content-Type: $contentType');
    switch (contentType?.toLowerCase()) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'image/webp':
        return '.webp';
      default:
        return '.png'; // 기본값
    }
  }

  Future<File> convertImageUrlToFile(String imageUrl) async {
    try {
      final imageDioResponse = await getImageBytes(imageUrl);
      final extension = _getImageExtension(imageDioResponse.data);
      final dateTime = DateTime.now();
      final formattedDateTime = DateFormat('yyyyMMdd_HHmmss').format(dateTime);
      final outputDirPath = DirectoryPaths.output.buildPath;

      await _ensureDirectoryExists(outputDirPath);

      final outputFilePath = path.join(outputDirPath, '$formattedDateTime.$extension');
      final backPhotoFile = File(outputFilePath);

      await backPhotoFile.writeAsBytes(imageDioResponse.data);

      return backPhotoFile;
    } catch (e) {
      throw Exception('Failed convertImageUrlToFile: $e');
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

  Future<void> _ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }
}

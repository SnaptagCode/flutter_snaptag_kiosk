import 'package:dio/dio.dart' as dio show Dio, Options, ResponseType, Response;
import 'package:flutter_snaptag_kiosk/lib.dart';

class ImageHelper {
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
    logger.d('Content-Type: $contentType');
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
}

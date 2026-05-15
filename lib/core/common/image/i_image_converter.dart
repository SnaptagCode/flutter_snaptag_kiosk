import 'dart:io';

abstract interface class IImageConverter {
  Future<File> convertImageUrlToFile(String imageUrl);
}

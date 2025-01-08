import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_snaptag_kiosk/core/constants/constants.dart';
import 'package:flutter_snaptag_kiosk/core/errors/errors.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class FileSystemService {
  const FileSystemService._();

  static final instance = FileSystemService._();

  String getFilePath(DirectoryPaths directory, {String? fileName}) {
    return path.join(Directory.current.path, directory.name, fileName);
  }

  Future<void> ensureDirectoryExists(DirectoryPaths directory) async {
    final dirPath = getFilePath(directory);
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  void openDirectory(DirectoryPaths directory) {
    final uri = Uri.file(getFilePath(directory));
    launchUrl(uri);
  }

  Future<void> copyPathToClipboard(DirectoryPaths directory, {String? fileName}) async {
    if (fileName == null) {
      final dirPath = getFilePath(directory);
      await Clipboard.setData(ClipboardData(text: dirPath));
    } else {
      final filePath = getFilePath(directory, fileName: fileName);
      await Clipboard.setData(ClipboardData(text: filePath));
    }
  }

  Future<void> clearDirectory(DirectoryPaths directory) async {
    try {
      final dirPath = getFilePath(directory);
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      throw StorageException(
        StorageErrorType.deleteError,
        path: getFilePath(directory),
        originalError: e,
      );
    }
  }
}

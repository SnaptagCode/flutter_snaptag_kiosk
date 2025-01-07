import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_snaptag_kiosk/core/constants/constants.dart';
import 'package:flutter_snaptag_kiosk/core/exceptions/exceptions.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class FileSystemService {
  const FileSystemService._();

  static final instance = FileSystemService._();

  String getDirectoryPath(DirectoryPaths directory) {
    return path.join(Directory.current.path, directory.name);
  }

  String getFilePath(DirectoryPaths directory, String fileName) {
    return path.join(getDirectoryPath(directory), fileName);
  }

  Future<void> ensureDirectoryExists(DirectoryPaths directory) async {
    final dirPath = getDirectoryPath(directory);
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  void openFileLocation(DirectoryPaths directory, String fileName) {
    final filePath = getFilePath(directory, fileName);
    final uri = Uri.file(filePath);
    launchUrl(uri);
  }

  void openDirectory(DirectoryPaths directory) {
    final uri = Uri.file(getDirectoryPath(directory));
    launchUrl(uri);
  }

  Future<void> copyPathToClipboard(DirectoryPaths directory, String fileName) async {
    final filePath = getFilePath(directory, fileName);
    await Clipboard.setData(ClipboardData(text: filePath));
  }

  Future<void> clearDirectory(DirectoryPaths directory) async {
    try {
      final dirPath = getDirectoryPath(directory);
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      throw StorageException(
        StorageErrorType.deleteError,
        path: getDirectoryPath(directory),
        originalError: e,
      );
    }
  }
}

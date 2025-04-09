import 'dart:io';

import 'package:path/path.dart' as path;

enum DirectoryPaths {
  // Root directories (parent == null)
  assets('assets'),
  embeddings('embeddings'),

  settings('settings'),

  // Sub directories
  settingImages('setting_images', parent: settings),
  frontImages('front_images', parent: settings),
  labcurity('labcurity', parent: assets),
  luca('luca', parent: assets),
  input('images', parent: embeddings),
  output('output', parent: embeddings);

  const DirectoryPaths(this.name, {this.parent});

  final String name;
  final DirectoryPaths? parent;

  bool get isBase => parent == null;

  String get buildPath => _buildPath();
  String _buildPath() {
    final segments = <String>[Directory.current.path];
    DirectoryPaths? current = this;
    final parts = <String>[];

    while (current != null) {
      parts.add(current.name);
      current = current.parent;
    }
    segments.addAll(parts.reversed);

    return path.joinAll(segments);
  }
}

enum FilePaths {
  labcurityKey('labcurity_key.txt', directory: DirectoryPaths.labcurity),
  labcurityDLL('LabCode_x64.dll', directory: DirectoryPaths.labcurity),
  labcuritySetting('setting_file.txt', directory: DirectoryPaths.labcurity),
  labcurityCode('foxtrot_code.json', directory: DirectoryPaths.labcurity),
  printerDLL('libDSRetransfer600App.dll', directory: DirectoryPaths.luca);

  const FilePaths(this.name, {required this.directory});

  final String name;
  final DirectoryPaths directory;

  String get buildPath => path.join(directory.buildPath, name);
}

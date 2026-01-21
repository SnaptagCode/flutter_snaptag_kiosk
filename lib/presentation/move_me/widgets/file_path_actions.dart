import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/core/constants/constants.dart';
import 'package:flutter_snaptag_kiosk/core/data/data.dart';

class FilePathActions extends StatelessWidget {
  const FilePathActions({
    super.key,
    required this.directory,
    this.fileName,
    this.showOpenDirectory = true,
  });

  final DirectoryPaths directory;
  final String? fileName;
  final bool showOpenDirectory;

  @override
  Widget build(BuildContext context) {
    final fileSystem = FileSystemService.instance;

    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showOpenDirectory)
            IconButton(
              icon: const Icon(Icons.folder),
              onPressed: () => fileSystem.openDirectory(directory),
              tooltip: 'Open directory',
            ),
          Flexible(
            child: Text(
              'Path: ${fileSystem.getFilePath(directory, fileName: fileName)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await fileSystem.copyPathToClipboard(directory, fileName: fileName);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Path copied to clipboard')),
                );
              }
            },
            tooltip: 'Copy path',
          ),
        ],
      ),
    );
  }
}

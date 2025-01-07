import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/constants/constants.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class ImageStorageScreen extends ConsumerWidget {
  const ImageStorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileSystem = FileSystemService.instance;
    final imagePath = fileSystem.getFilePath(DirectoryPaths.frontImages, 'test_image.jpg');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Storage Test'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 저장 버튼
            ElevatedButton(
              onPressed: () async {
                try {
                  final imageStorage = ref.read(imageStorageProvider);
                  await imageStorage.saveImage(
                    DirectoryPaths.frontImages,
                    'https://picsum.photos/id/1/200/300',
                    'test_image',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미지 저장 성공!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('이미지 저장 실패: $e')),
                    );
                  }
                }
              },
              child: const Text('Save Image'),
            ),
            const SizedBox(height: 20),

            // 저장된 이미지 표시
            Image.file(
              File(imagePath),
              height: 300,
              width: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Text('이미지를 찾을 수 없습니다.');
              },
            ),
            const SizedBox(height: 20),

            // 이미지 삭제 버튼
            ElevatedButton(
              onPressed: () async {
                try {
                  await fileSystem.clearDirectory(DirectoryPaths.frontImages);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미지 삭제 성공!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('이미지 삭제 실패: $e')),
                    );
                  }
                }
              },
              child: const Text('Clear Images'),
            ),
            FilePathActions(
              directory: DirectoryPaths.frontImages,
              fileName: 'test_image.jpg',
            ),
          ],
        ),
      ),
    );
  }
}

class FilePathActions extends StatelessWidget {
  const FilePathActions({
    super.key,
    required this.directory,
    required this.fileName,
    this.showOpenDirectory = true,
  });

  final DirectoryPaths directory;
  final String fileName;
  final bool showOpenDirectory;

  @override
  Widget build(BuildContext context) {
    final fileSystem = FileSystemService.instance;

    return Row(
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
            'Path: ${fileSystem.getFilePath(directory, fileName)}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () async {
            await fileSystem.copyPathToClipboard(directory, fileName);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Path copied to clipboard')),
              );
            }
          },
          tooltip: 'Copy path',
        ),
        IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => fileSystem.openFileLocation(directory, fileName),
          tooltip: 'Open file location',
        ),
      ],
    );
  }
}

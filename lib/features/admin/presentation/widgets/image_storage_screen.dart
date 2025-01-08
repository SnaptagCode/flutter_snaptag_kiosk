import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class FrontImagesStore extends ConsumerWidget {
  const FrontImagesStore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  await ref
                      .read(frontPhotoListProvider.notifier)
                      .fetch(ref.watch(storageServiceProvider).settings.kioskEventId);
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
            Consumer(builder: (context, ref, child) {
              final frontPhotoListState = ref.watch(frontPhotoListProvider);
              final List<FrontPhotoPath> frontPhotoList = frontPhotoListState ?? [];
              return Wrap(
                children: [
                  for (final photo in frontPhotoList)
                    Image.file(
                      File(photo.localPath),
                      width: 200,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                ],
              );
            }),
            const SizedBox(height: 20),

            // 이미지 삭제 버튼
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(frontPhotoListProvider.notifier).clearImages();
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
            ),
          ],
        ),
      ),
    );
  }
}

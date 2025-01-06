import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class ImageStorageScreen extends ConsumerWidget {
  const ImageStorageScreen({super.key});

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
            ElevatedButton(
              onPressed: () async {
                try {
                  final imageStorage = ref.read(imageStorageProvider);
                  await imageStorage.saveImage(
                    'https://picsum.photos/id/1/200/300',
                    'test_image.jpg',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이미지 저장 성공!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이미지 저장 실패: $e')),
                  );
                }
              },
              child: const Text('Save Image'),
            ),
            const SizedBox(height: 20),
            // 저장된 이미지 표시
            Consumer(
              builder: (context, ref, child) {
                final imageStorage = ref.watch(imageStorageProvider);
                final imagePath = imageStorage.getImagePath('test_image.jpg');
                if (imagePath == null) {
                  return const Text('No saved image');
                }
                return FutureBuilder(
                  future: File(imagePath).exists(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Column(
                        children: [
                          Image.file(
                            File(imagePath),
                            height: 300,
                            width: 200,
                          ),
                          const SizedBox(height: 10),
                          Text('Image path: $imagePath'),
                        ],
                      );
                    }
                    return const Text('No saved image');
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final imageStorage = ref.read(imageStorageProvider);
                  await imageStorage.clearImages();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이미지 삭제 성공!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이미지 삭제 실패: $e')),
                  );
                }
              },
              child: const Text('Clear Images'),
            ),
          ],
        ),
      ),
    );
  }
}

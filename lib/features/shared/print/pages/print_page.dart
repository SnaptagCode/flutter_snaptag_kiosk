import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/admin/providers/front_photo_list.dart';
import 'package:flutter_snaptag_kiosk/features/shared/labcurity/providers/labcurity_provider.dart';
import 'package:flutter_snaptag_kiosk/features/shared/print/printer/card_printer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_page.g.dart';

@riverpod
class ProcessedImage extends _$ProcessedImage {
  @override
  Future<Uint8List?> build() async {
    return null;
  }

  Future<void> processAndPrint(String imagePath, bool isPrint) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // 1. 랜덤 이미지 선택
      final frontPhotoList = ref.read(frontPhotoListProvider.notifier);
      final randomPhoto = frontPhotoList.getRandomPhoto();
      if (randomPhoto == null) {
        throw Exception('No front images available');
      }

      // 2. 이미지 읽기
      final imageBytes = await File(imagePath).readAsBytes();

      // 3. Labcurity 처리
      final labcurityImage = ref.read(labcurityImageProvider.notifier);
      await labcurityImage.embedImage(imageBytes);
      final processedImage = await ref.read(labcurityImageProvider.future);

      if (processedImage == null) {
        throw Exception('Failed to process image with Labcurity');
      }

      // 3. 프린트 요청
      // 임시 파일로 저장
      final tempFile = File('${imagePath}_processed.png');
      await tempFile.writeAsBytes(processedImage);

      try {
        await ref.read(printerStateProvider.notifier).printImage(
              frontImagePath: randomPhoto.path,
              backImagePath: tempFile.path,
            );
      } finally {
        // 임시 파일 삭제
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }

      return processedImage;
    });
  }
}

class PrintTestScreen extends ConsumerWidget {
  const PrintTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frontPhotoListState = ref.watch(frontPhotoListProvider);
    final processedImageState = ref.watch(processedImageProvider);
    final printerState = ref.watch(printerStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Labcurity Print Test'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 원본 이미지 표시
                  if (frontPhotoListState.isNotEmpty) ...[
                    const Text('Original Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Image.file(
                      File(frontPhotoListState[0]),
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 처리된 이미지 표시
                  processedImageState.when(
                    data: (processedImage) {
                      if (processedImage != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Processed Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Image.memory(
                              processedImage,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Error: $error', style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ),

          // 컨트롤 버튼들
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: frontPhotoListState.isEmpty
                      ? null
                      : () => ref.read(processedImageProvider.notifier).processAndPrint(
                            frontPhotoListState[0],
                            false,
                          ),
                  child: const Text('Process Image'),
                ),
                ElevatedButton(
                  onPressed: frontPhotoListState.isEmpty || printerState.isLoading
                      ? null
                      : () => ref.read(processedImageProvider.notifier).processAndPrint(
                            frontPhotoListState[0],
                            true,
                          ),
                  child: const Text('Process & Print'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

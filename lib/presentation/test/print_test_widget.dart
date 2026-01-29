import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

part 'print_test_widget.g.dart';

@riverpod
class ProcessedImage extends _$ProcessedImage {
  @override
  ({File? frontFile, Uint8List? backImage}) build() {
    return (frontFile: null, backImage: null);
  }

  Future<void> selectRandomImage() async {
    // 1. 랜덤 이미지 선택
    final frontPhotoList = ref.read(frontPhotoListProvider.notifier);
    final randomPhoto = await frontPhotoList.getRandomPhoto();
    state = (frontFile: randomPhoto.safeEmbedImage, backImage: state.backImage);
  }

  Future<void> selectBackImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        state = (frontFile: state.frontFile, backImage: result.files.single.bytes);
      }
    } catch (e) {
      debugPrint('Error picking or processing image: $e');
    }
  }

  Future<void> printImages(PagePrintType type) async {
    if (type == PagePrintType.single) {
      if (state.frontFile == null) {
        throw Exception('Front image must be selected');
      }

      try {
        await ref.read(printerServiceProvider.notifier).printImage(
              frontFile: state.frontFile!,
              embeddedFile: null,
              isSingleMode: type == PagePrintType.single,
            );
      } finally {}
      return;
    }

    if (state.frontFile == null || state.backImage == null) {
      throw Exception('Both images must be selected');
    }

    final tempFile = File('${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(state.backImage!);

    try {
      await ref.read(printerServiceProvider.notifier).printImage(
            frontFile: state.frontFile!,
            embeddedFile: tempFile,
            isSingleMode: type == PagePrintType.single,
          );
    } catch (e) {
      rethrow;
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  void clear() {
    state = (frontFile: null, backImage: null);
  }
}

class PrintTestWidget extends ConsumerWidget {
  const PrintTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processedImages = ref.watch(processedImageProvider);
    final printerState = ref.watch(printerServiceProvider);
    final pagePrintType = ref.watch(pagePrintProvider);
    final canPrint = pagePrintType == PagePrintType.double
        ? processedImages.frontFile != null && processedImages.backImage != null && !printerState.isLoading
        : processedImages.frontFile != null && !printerState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 이미지 선택 및 표시 영역
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Front Image'),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: processedImages.frontFile != null
                        ? Image.file(processedImages.frontFile!)
                        : const Center(child: Text('No image selected')),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.read(processedImageProvider.notifier).selectRandomImage(),
                    child: const Text('Random Front Image'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text('Back Image'),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: processedImages.backImage != null
                        ? Image.memory(processedImages.backImage!)
                        : const Center(child: Text('No image selected')),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.read(processedImageProvider.notifier).selectBackImage(),
                    child: const Text('Select Back Image'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (printerState.hasError)
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            color: Colors.red.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '프린터 오류: ${printerState.error.toString()}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.refresh(printerServiceProvider),
                ),
              ],
            ),
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: canPrint
                  ? () async {
                      try {
                        await ref.read(processedImageProvider.notifier).printImages(pagePrintType);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('인쇄가 완료되었습니다')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('인쇄 실패: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              child: const Text('Print Images'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => ref.read(processedImageProvider.notifier).clear(),
              child: const Text('Clear Images'),
            ),
          ],
        ),
      ],
    );
  }
}

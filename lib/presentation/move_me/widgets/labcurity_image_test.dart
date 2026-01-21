// features/security_image_test/presentation/views/security_image_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/labcurity/labcurity_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/widgets/general_error_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'labcurity_image_test.g.dart';

@riverpod
class LabcurityImageTest extends _$LabcurityImageTest {
  @override
  Future<File?> build() {
    return Future.value(null);
  }

  Future<void> embedImage(Uint8List imageData, [LabcurityImageConfig? config]) async {
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final service = ref.read(labcurityServiceProvider);
        return service.embedImage(imageData, config);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class LabcurityImageTestWidget extends ConsumerWidget {
  const LabcurityImageTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityImageState = ref.watch(labcurityImageTestProvider);

    return Column(
      children: [
        securityImageState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => GeneralErrorWidget(
            exception: error as Exception,
            onRetry: () => ref.refresh(labcurityImageTestProvider),
          ),
          data: (processedImage) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => _pickAndProcessImage(ref),
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 20),
              if (processedImage != null) ...[
                const Text(
                  'Processed Image:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Image.file(
                  processedImage,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndProcessImage(WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final imageBytes = await file.readAsBytes();

        await ref.read(labcurityImageTestProvider.notifier).embedImage(
              imageBytes,
              const LabcurityImageConfig(
                size: 3,
                strength: 16,
              ),
            );
      }
    } catch (e) {
      debugPrint('Error picking or processing image: $e');
    }
  }
}

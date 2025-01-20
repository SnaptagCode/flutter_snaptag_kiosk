// features/security_image_test/presentation/views/security_image_screen.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/security_image_config.dart';
import '../providers/labcurity_provider.dart';

class LabcurityImageScreen extends ConsumerWidget {
  const LabcurityImageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityImageState = ref.watch(labcurityImageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Image Test'),
      ),
      body: securityImageState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (processedImage) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                Image.memory(
                  processedImage,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ],
            ],
          ),
        ),
      ),
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

        await ref.read(labcurityImageProvider.notifier).embedImage(
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

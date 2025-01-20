import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/shared/labcurity/services/labcurity_library.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/security_image_config.dart';
import '../services/labcurity_service.dart';

part 'labcurity_provider.g.dart';

@riverpod
LabcurityLibrary labcurityLibrary(Ref ref) {
  return LabcurityLibrary();
}

@riverpod
LabcurityService labcurityService(LabcurityServiceRef ref) {
  final library = ref.watch(labcurityLibraryProvider);
  return LabcurityService(library);
}

@riverpod
class LabcurityImage extends _$LabcurityImage {
  @override
  Future<Uint8List?> build() {
    return Future.value(null);
  }

  Future<void> embedImage(Uint8List imageData, [LabcurityImageConfig? config]) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(labcurityServiceProvider);
      return service.embedImage(imageData, config);
    });
  }
}

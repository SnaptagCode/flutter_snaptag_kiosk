import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/core/labcurity/services/labcurity_library.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

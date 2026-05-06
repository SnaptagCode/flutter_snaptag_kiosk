import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BackPhotoType {
  custom,
}

class BackPhotoSelection {
  final BackPhotoType type;

  const BackPhotoSelection({required this.type});

  factory BackPhotoSelection.custom() {
    return const BackPhotoSelection(type: BackPhotoType.custom);
  }
}

class BackPhotoTypeNotifier extends StateNotifier<BackPhotoSelection?> {
  BackPhotoTypeNotifier() : super(null);

  void selectCustom() {
    state = BackPhotoSelection.custom();
  }

  void reset() => state = null;
}

final backPhotoTypeProvider = StateNotifierProvider<BackPhotoTypeNotifier, BackPhotoSelection?>(
  (ref) => BackPhotoTypeNotifier(),
);

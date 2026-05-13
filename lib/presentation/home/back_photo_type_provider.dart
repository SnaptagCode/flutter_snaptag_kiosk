import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'back_photo_type_provider.g.dart';

enum BackPhotoType {
  fixed,
  custom,
}

class BackPhotoSelection {
  final BackPhotoType type;
  final int? fixedIndex;

  const BackPhotoSelection({required this.type, this.fixedIndex});

  factory BackPhotoSelection.fixed(int index) =>
      BackPhotoSelection(type: BackPhotoType.fixed, fixedIndex: index);

  factory BackPhotoSelection.custom() =>
      BackPhotoSelection(type: BackPhotoType.custom);
}

@Riverpod(keepAlive: true)
class BackPhotoTypeNotifier extends _$BackPhotoTypeNotifier {
  @override
  BackPhotoSelection? build() => null;

  void selectFixed(int index) => state = BackPhotoSelection.fixed(index);
  void selectCustom() => state = BackPhotoSelection.custom();
  void reset() => state = null;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_back_photo_type_notifier.g.dart';

enum BackPhotoType {
  fixed,
  custom,
}

class BackPhotoSelection {
  final BackPhotoType type;
  final int? fixedIndex;

  const BackPhotoSelection({required this.type, this.fixedIndex});

  // 추천 이미지 선택
  factory BackPhotoSelection.fixed(int index) => BackPhotoSelection(type: BackPhotoType.fixed, fixedIndex: index);

  // 내 사진 업로드(QR -> 인증번호 입력)
  factory BackPhotoSelection.custom() => BackPhotoSelection(type: BackPhotoType.custom);
}

@Riverpod(keepAlive: true)
class BackPhotoTypeNotifier extends _$BackPhotoTypeNotifier {
  @override
  BackPhotoSelection? build() => null;

  void selectFixed(int index) => state = BackPhotoSelection.fixed(index);
  void selectCustom() => state = BackPhotoSelection.custom();
  void reset() => state = null;
}

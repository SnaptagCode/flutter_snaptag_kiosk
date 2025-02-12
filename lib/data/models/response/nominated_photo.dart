import 'package:freezed_annotation/freezed_annotation.dart';

part 'nominated_photo.freezed.dart';
part 'nominated_photo.g.dart';

@freezed
class NominatedPhoto with _$NominatedPhoto {
  const factory NominatedPhoto({
    required int id,
    required int embeddingProductId,
    required int code,
    required String originUrl,
    required String embedUrl,
    required int selectionWeight,
    required bool isWin,
  }) = _NominatedPhoto;

  factory NominatedPhoto.fromJson(Map<String, dynamic> json) =>
      _$NominatedPhotoFromJson(json);
}

// '{id}_{code}_{embeddingProductId}_{selectedWeight}_{isWin}.확장자' 형식
// - isWin 은 true 일 때 1, false 일 때 0
extension ObjectToFileName on NominatedPhoto {
  String getFileName() =>
      '${id}_${code}_${embeddingProductId}_${selectionWeight}_${isWin ? 1 : 0}';
}

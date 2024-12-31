import 'package:freezed_annotation/freezed_annotation.dart';

part 'nominated_photo.freezed.dart';
part 'nominated_photo.g.dart';

@freezed
class NominatedPhoto with _$NominatedPhoto {
  const factory NominatedPhoto({
    required int id,
    required int embeddingProductId,
    required String embeddedUrl,
  }) = _NominatedPhoto;

  factory NominatedPhoto.fromJson(Map<String, dynamic> json) => _$NominatedPhotoFromJson(json);
}

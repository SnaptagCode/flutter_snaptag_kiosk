import 'package:flutter_snaptag_kiosk/data/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'front_photo_path.freezed.dart';

@freezed
class FrontPhotoPath with _$FrontPhotoPath {
  const factory FrontPhotoPath({
    required NominatedPhoto photo,
    required String localPath,
  }) = _FrontPhotoPath;
}

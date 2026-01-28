import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'nominated_photo_list.freezed.dart';
part 'nominated_photo_list.g.dart';

@freezed
class NominatedPhotoList with _$NominatedPhotoList {
  const factory NominatedPhotoList({
    required List<NominatedPhoto> list,
  }) = _NominatedPhotoList;

  factory NominatedPhotoList.fromJson(Map<String, dynamic> json) => _$NominatedPhotoListFromJson(json);
}

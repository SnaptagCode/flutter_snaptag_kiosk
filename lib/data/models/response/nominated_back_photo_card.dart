import 'package:freezed_annotation/freezed_annotation.dart';

part 'nominated_back_photo_card.freezed.dart';
part 'nominated_back_photo_card.g.dart';

@freezed
class NominatedBackPhotoCard with _$NominatedBackPhotoCard {
  const factory NominatedBackPhotoCard({
    required int id,
    required String originUrl,
  }) = _NominatedBackPhotoCard;

  factory NominatedBackPhotoCard.fromJson(Map<String, dynamic> json) => _$NominatedBackPhotoCardFromJson(json);
}
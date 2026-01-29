import 'package:flutter_snaptag_kiosk/core/data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'back_photo_for_print.freezed.dart';
part 'back_photo_for_print.g.dart';

@freezed
class BackPhotoForPrint with _$BackPhotoForPrint {
  const factory BackPhotoForPrint({
    required int backPhotoCardId,
    @JsonKey(defaultValue: 0) required int nominatedBackPhotoCardId,
    required int kioskEventId,
    required int embeddingProductId,
    required String photoAuthNumber,
    required PrintedStatus status,
    required String formattedImageUrl,
    required int versionCode,
    required int countryCode,
    required int industryCode,
    required int customerCode,
    required int projectCode,
    required int productCode,
  }) = _BackPhotoForPrint;

  factory BackPhotoForPrint.fromJson(Map<String, dynamic> json) => _$BackPhotoForPrintFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';

part 'update_print_response.freezed.dart';
part 'update_print_response.g.dart';

@freezed
class UpdatePrintResponse with _$UpdatePrintResponse {
  const factory UpdatePrintResponse({
    required int kioskEventId,
    required int backPhotoId,
    required PrintStatus status,
    required bool isEmbedded,
    required int printedPhotoCardId,
  }) = _UpdatePrintResponse;

  factory UpdatePrintResponse.fromJson(Map<String, dynamic> json) => _$UpdatePrintResponseFromJson(json);
}

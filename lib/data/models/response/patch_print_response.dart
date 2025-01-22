import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';

part 'patch_print_response.freezed.dart';
part 'patch_print_response.g.dart';

@freezed
class PatchPrintResponse with _$PatchPrintResponse {
  const factory PatchPrintResponse({
    required int kioskEventId,
    required PrintedStatus status,
    required int printedPhotoCardId,
  }) = _PatchPrintResponse;

  factory PatchPrintResponse.fromJson(Map<String, dynamic> json) => _$PatchPrintResponseFromJson(json);
}

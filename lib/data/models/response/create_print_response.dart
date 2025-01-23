import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_print_response.freezed.dart';
part 'create_print_response.g.dart';

@freezed
class CreatePrintResponse with _$CreatePrintResponse {
  const factory CreatePrintResponse({
    required int kioskEventId,
    required int backPhotoId,
    required int printedPhotoCardId,
  }) = _CreatePrintResponse;

  factory CreatePrintResponse.fromJson(Map<String, dynamic> json) => _$CreatePrintResponseFromJson(json);
}

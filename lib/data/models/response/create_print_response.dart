import 'package:flutter_snaptag_kiosk/domain/models/print/print_job_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_print_response.freezed.dart';
part 'create_print_response.g.dart';

@freezed
class CreatePrintResponse with _$CreatePrintResponse {
  const factory CreatePrintResponse({
    required int kioskEventId,
    required int backPhotoId,
    required int printedPhotoCardId,
    required String formattedImageUrl,
  }) = _CreatePrintResponse;

  factory CreatePrintResponse.fromJson(Map<String, dynamic> json) => _$CreatePrintResponseFromJson(json);
}

extension CreatePrintResponseMapper on CreatePrintResponse {
  PrintJobResult toDomain() => PrintJobResult(
        kioskEventId: kioskEventId,
        backPhotoId: backPhotoId,
        printedPhotoCardId: printedPhotoCardId,
        formattedImageUrl: formattedImageUrl,
      );
}

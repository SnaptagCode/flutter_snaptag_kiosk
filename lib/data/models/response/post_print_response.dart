import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';

part 'post_print_response.freezed.dart';
part 'post_print_response.g.dart';

@freezed
class PostPrintResponse with _$PostPrintResponse {
  const factory PostPrintResponse({
    required int kioskEventId,
    required int backPhotoId,
    required int printedPhotoCardId,
  }) = _PostPrintResponse;

  factory PostPrintResponse.fromJson(Map<String, dynamic> json) => _$PostPrintResponseFromJson(json);
}

import 'dart:io';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_print_request.freezed.dart';
part 'post_print_request.g.dart';

@freezed
class PostPrintRequest with _$PostPrintRequest {
  factory PostPrintRequest({
    required int kioskMachineId,
    required int kioskEventId,
    required int frontPhotoCardId,
    required String photoAuthNumber,
    required PrintedStatus status,
    @JsonKey(includeToJson: false, includeFromJson: false) File? file,
    int? printedPhotoCardId,
  }) = _PostPrintRequest;
  factory PostPrintRequest.fromJson(Map<String, dynamic> json) => _$PostPrintRequestFromJson(json);
}

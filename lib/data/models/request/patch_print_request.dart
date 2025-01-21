import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'patch_print_request.freezed.dart';
part 'patch_print_request.g.dart';

@freezed
class PatchPrintRequest with _$PatchPrintRequest {
  factory PatchPrintRequest({
    required int kioskMachineId,
    required int kioskEventId,
    required int frontPhotoCardId,
    required String photoAuthNumber,
    required PrintedStatus status,
    @JsonKey(includeToJson: false, includeFromJson: false) File? file,
    int? printedPhotoCardId,
  }) = _PatchPrintRequest;
  factory PatchPrintRequest.fromJson(Map<String, dynamic> json) => _$PatchPrintRequestFromJson(json);
}

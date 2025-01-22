import 'dart:io';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'patch_print_request.freezed.dart';
part 'patch_print_request.g.dart';

@freezed
class PatchPrintRequest with _$PatchPrintRequest {
  factory PatchPrintRequest({
    required int kioskMachineId,
    required int kioskEventId,
    required PrintedStatus status,
  }) = _PatchPrintRequest;
  factory PatchPrintRequest.fromJson(Map<String, dynamic> json) => _$PatchPrintRequestFromJson(json);
}

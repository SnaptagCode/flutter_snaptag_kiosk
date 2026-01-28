import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_print_request.freezed.dart';
part 'create_print_request.g.dart';

@freezed
class CreatePrintRequest with _$CreatePrintRequest {
  factory CreatePrintRequest({
    required int kioskMachineId,
    required int kioskEventId,
    required int frontPhotoCardId,
    required int backPhotoCardId,
  }) = _CreatePrintRequest;
  factory CreatePrintRequest.fromJson(Map<String, dynamic> json) => _$CreatePrintRequestFromJson(json);
}

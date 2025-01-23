import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_print_request.freezed.dart';
part 'update_print_request.g.dart';

@freezed
class UpdatePrintRequest with _$UpdatePrintRequest {
  factory UpdatePrintRequest({
    required int kioskMachineId,
    required int kioskEventId,
    required PrintedStatus status,
  }) = _UpdatePrintRequest;
  factory UpdatePrintRequest.fromJson(Map<String, dynamic> json) => _$UpdatePrintRequestFromJson(json);
}

import 'package:flutter_snaptag_kiosk/core/data/models/enums/order_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_machine_job_order_request.freezed.dart';
part 'update_machine_job_order_request.g.dart';

@freezed
class UpdateMachineJobOrderRequest with _$UpdateMachineJobOrderRequest {
  factory UpdateMachineJobOrderRequest({
    required int kioskEventId,
    required int kioskMachineId,
    required OrderStatus status,
    required int amount,
    required String authSeqNumber,
    required String approvalNumber,
    String? description,
    @Default('{}') String detail,
  }) = _UpdateMachineJobOrderRequest;

  factory UpdateMachineJobOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMachineJobOrderRequestFromJson(json);
}

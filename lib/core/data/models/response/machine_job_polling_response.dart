import 'package:flutter_snaptag_kiosk/core/data/models/enums/machine_job_type.dart';
import 'package:flutter_snaptag_kiosk/core/data/models/response/refund_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'machine_job_polling_response.freezed.dart';
part 'machine_job_polling_response.g.dart';

@freezed
class MachineJobPollingResponse with _$MachineJobPollingResponse {
  const factory MachineJobPollingResponse({
    required bool exists,
    int? printJobId,
    MachineJobType? type,
    RefundInfo? refundInfo,
  }) = _MachineJobPollingResponse;

  factory MachineJobPollingResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineJobPollingResponseFromJson(json);
}

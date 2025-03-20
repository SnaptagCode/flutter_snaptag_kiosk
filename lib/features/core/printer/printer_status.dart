import 'package:freezed_annotation/freezed_annotation.dart';

part 'printer_status.freezed.dart';
part 'printer_status.g.dart';

@freezed
class PrinterStatus with _$PrinterStatus {
  const factory PrinterStatus({
    required int machineId,
    required int mainCode,
    required int subCode,
    required int mainStatus,
    required int errorStatus,
    required int warningStatus,
    required int chassisTemperature,
    required int printHeadTemperature,
    required int heaterTemperature,
    required int subStatus,
  }) = _PrinterStatus;

  factory PrinterStatus.fromJson(Map<String, dynamic> json) => _$PrinterStatusFromJson(json);
}

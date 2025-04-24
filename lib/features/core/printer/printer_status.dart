/*class PrinterStatus {
  final int mainCode;
  final int subCode;
  final int mainStatus;
  final int errorStatus;
  final int warningStatus;
  final int chassisTemperature;
  final int printHeadTemperature;
  final int heaterTemperature;
  final int subStatus;*/

import 'package:freezed_annotation/freezed_annotation.dart';
/*  const PrinterStatus({
    required this.mainCode,
    required this.subCode,
    required this.mainStatus,
    required this.errorStatus,
    required this.warningStatus,
    required this.chassisTemperature,
    required this.printHeadTemperature,
    required this.heaterTemperature,
    required this.subStatus,
  });*/
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

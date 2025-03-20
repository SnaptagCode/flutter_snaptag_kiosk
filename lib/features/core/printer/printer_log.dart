import 'package:flutter_snaptag_kiosk/features/core/printer/printer_status.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'printer_log.freezed.dart';
part 'printer_log.g.dart';

// @freezed
// class PrinterLog with _$PrinterLog {
//   const factory PrinterLog({
//     @Default(null) PrinterStatus? printerStatus,
//     @Default(null) RibbonStatus? ribbonStatus,
//     @Default(null) bool? isPrintingNow,
//     @Default(null) bool? isFeederEmpty,
//     @Default(null) String? errorMsg,
//   }) = _PrinterLog;

//   factory PrinterLog.fromJson(Map<String, dynamic> json) => _$PrinterLogFromJson(json);
// }

@freezed
class PrinterLog with _$PrinterLog {
  const factory PrinterLog({
    @Default(0) int kioskMachineId,
    @Default('0') String sdkMainCode,
    @Default('0') String sdkSubCode,
    @Default('0') String printerMainStatusCode,
    @Default('0') String printerErrorStatusCode,
    @Default('0') String printerWarningStatusCode,
    @Default(0) int chassisTemperature,
    @Default(0) int printHeadTemperature,
    @Default(0) int heaterTemperature,
    @Default(0) int rbnRemainingRatio,
    @Default(0) int filmRemainingRatio,
    @Default(null) bool? isPrintingNow,
    @Default(null) bool? isFeederEmpty,
    @Default(null) String? sdkErrorMessage,
  }) = _PrinterLog;

  factory PrinterLog.fromJson(Map<String, dynamic> json) => _$PrinterLogFromJson(json);
}

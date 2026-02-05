import 'package:freezed_annotation/freezed_annotation.dart';

part 'printer_log.freezed.dart';
part 'printer_log.g.dart';

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
    @Default(0) int printerHeadTemperature,
    @Default(0) int heaterTemperature,
    @Default(0) int rbnRemainingRatio,
    @Default(0) int filmRemainingRatio,
    @Default(null) bool? isPrintingNow,
    @Default(null) bool? isFeederEmpty,
    @Default(null) String? sdkErrorMessage,
    @Default(null) String? remainingSingleSidedCountPre,
    @Default(null) String? remainingSingleSidedCountPost,
  }) = _PrinterLog;

  factory PrinterLog.fromJson(Map<String, dynamic> json) => _$PrinterLogFromJson(json);
}

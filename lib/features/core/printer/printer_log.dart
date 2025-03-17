import 'package:flutter_snaptag_kiosk/features/core/printer/printer_status.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'printer_log.freezed.dart';
part 'printer_log.g.dart';

@freezed
class PrinterLog with _$PrinterLog {
  const factory PrinterLog({
    @Default(null) PrinterStatus? printerStatus,
    @Default(null) RibbonStatus? ribbonStatus,
    @Default(null) bool? isPrintingNow,
    @Default(null) bool? isFeederEmpty,
    @Default(null) String? errorMsg,
  }) = _PrinterLog;

  factory PrinterLog.fromJson(Map<String, dynamic> json) => _$PrinterLogFromJson(json);
}

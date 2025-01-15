import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'printer_settings.freezed.dart';
part 'printer_settings.g.dart';

@freezed
class PrinterSettings with _$PrinterSettings {
  const factory PrinterSettings({
    @Default(false) bool doubleSided,
    @Default(PrintMode.color) PrintMode printMode,
    @Default(10.0) double margin,
  }) = _PrinterSettings;
}

enum PrintMode {
  color,
  monochrome;

  int get value => index;
}

@riverpod
class PrinterSettingsState extends _$PrinterSettingsState {
  @override
  PrinterSettings build() {
    return const PrinterSettings();
  }

  void setDoubleSided(bool value) {
    state = state.copyWith(doubleSided: value);
  }

  void setPrintMode(PrintMode mode) {
    state = state.copyWith(printMode: mode);
  }

  void setMargin(double value) {
    state = state.copyWith(margin: value);
  }
}

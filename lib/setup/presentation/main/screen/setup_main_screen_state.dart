import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'setup_main_screen_state.freezed.dart';

@freezed
class SetupMainScreenState with _$SetupMainScreenState {
  const factory SetupMainScreenState({
    required PagePrintType pagePrintType,
    required int cardCount,
    required String currentVersion,
    required String latestVersion,
    required bool isPrinterConnected,
    required bool hasKioskInfo,
  }) = _SetupMainScreenState;
}

extension SetupMainScreenStateExtension on SetupMainScreenState {
  bool get isUpdateAvailable => currentVersion != latestVersion;
}

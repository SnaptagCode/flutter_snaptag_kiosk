import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_log.dart';

part 'print_state_provider.g.dart';

/// 프린터 상태(PrinterLog)를 보관하는 전역 Provider.
/// - 최신 프린트 상태를 저장/조회
/// - 필요 시 clear 가능
@Riverpod(keepAlive: true)
class PrintState extends _$PrintState {
  /// 초기값: 없음
  @override
  PrinterLog? build() => null;

  /// 상태 저장/갱신
  void set(PrinterLog? log) {
    state = log;
  }

  /// 상태 초기화
  void clear() {
    state = null;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/luca_printer_device.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/printer_device.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'printer_device_provider.g.dart';

/// 프린터 기기 교체 지점. Phase 1은 LUCA 단일 후보라 항상 LUCA를 반환한다.
/// 반드시 sync provider로 유지할 것 — async로 바꾸면 setup 2초 폴링이 영구 '점검중'이 된다.
/// 연결 판정은 기기의 isConnected에 위임하며, provider 단계의 probe/fallback은 금지.
@Riverpod(keepAlive: true)
PrinterDevice printerDevice(Ref ref) {
  return LucaPrinterDevice(ref);
}

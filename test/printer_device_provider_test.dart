import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/luca_printer_device.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/printer_device.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/printer_device_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 지난 JKLI-185 시도에서 provider를 async(Future<PrinterDevice>)로 만들어
  // setup 2초 폴링이 영구 '점검중'이 된 회귀를 방지하는 가드 테스트.
  test('printerDeviceProvider는 동기(sync)로 LucaPrinterDevice를 반환한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final PrinterDevice device = container.read(printerDeviceProvider);

    expect(device, isA<LucaPrinterDevice>());
  });
}

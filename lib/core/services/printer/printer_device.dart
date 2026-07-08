import 'package:flutter_snaptag_kiosk/core/services/printer/models/print_job.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/models/printer_log.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/models/ribbon_status.dart';

/// 프린터 기기 추상화. 앱이 필요로 하는 기기 동작만 노출한다 (isolate/FFI/캔버스 은닉).
///
/// 기본 구현(supportsCacheClear/clearCache)을 물려받아야 하므로
/// 구현체는 implements가 아닌 extends로 붙인다.
abstract class PrinterDevice {
  Future<bool> isConnected();

  Future<bool> ensureReady();

  /// 결제 전에 호출된다. 피더에 카드가 없으면 throw.
  Future<void> ensureFeederLoaded();

  Future<RibbonStatus> ribbonStatus();

  /// 기기 상태 로그 조회. 서버 보고는 PrinterService 책임.
  Future<PrinterLog?> readLog();

  /// 인쇄 전체 시퀀스를 실행하고 결과 로그를 반환한다.
  Future<PrinterLog?> print(PrintJob job);

  /// 기기 캐시(라이브러리) 초기화 지원 여부. LUCA만 true.
  bool get supportsCacheClear => false;

  Future<void> clearCache() async {}
}

class PrinterUnsupportedException implements Exception {
  final String message;

  const PrinterUnsupportedException([this.message = '현재 프린터에서 지원하지 않는 기능입니다.']);

  @override
  String toString() => message;
}

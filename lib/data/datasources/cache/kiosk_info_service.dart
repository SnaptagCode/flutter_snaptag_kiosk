import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_info_service.g.dart';

@Riverpod(keepAlive: true)
class KioskInfoService extends _$KioskInfoService {
  KioskMachineInfo _settings = KioskMachineInfo();

  @override
  KioskInfoService build() {
    return this;
  }

  /// 현재 Kiosk 설정 반환
  KioskMachineInfo get settings => _settings;

  /// 설정값 저장 (메모리 캐시)
  void saveSettings(KioskMachineInfo info) {
    _settings = info;
  }
}

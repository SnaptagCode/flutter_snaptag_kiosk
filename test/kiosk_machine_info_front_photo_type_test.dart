import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KioskMachineInfo.frontPhotoType (JKLI-175)', () {
    test('USER_SELECT 응답이면 선택형으로 판정한다', () {
      final info = KioskMachineInfo.fromJson({
        'kioskEventId': 335,
        'kioskMachineId': 9999,
        'frontPhotoType': 'USER_SELECT',
      });

      expect(info.frontPhotoType, 'USER_SELECT');
      expect(info.isFrontPhotoUserSelect, true);
    });

    test('RANDOM 응답이면 랜덤형으로 판정한다', () {
      final info = KioskMachineInfo.fromJson({
        'kioskEventId': 335,
        'kioskMachineId': 9999,
        'frontPhotoType': 'RANDOM',
      });

      expect(info.isFrontPhotoUserSelect, false);
    });

    test('필드가 없는 구버전 서버 응답은 RANDOM 기본값으로 동작한다', () {
      final info = KioskMachineInfo.fromJson({
        'kioskEventId': 335,
        'kioskMachineId': 9999,
      });

      expect(info.frontPhotoType, 'RANDOM');
      expect(info.isFrontPhotoUserSelect, false);
    });

    test('알 수 없는 값은 랜덤형으로 안전하게 처리한다', () {
      final info = KioskMachineInfo.fromJson({
        'kioskEventId': 335,
        'kioskMachineId': 9999,
        'frontPhotoType': 'SOMETHING_NEW',
      });

      expect(info.isFrontPhotoUserSelect, false);
    });
  });
}

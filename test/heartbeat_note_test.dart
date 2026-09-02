import 'package:flutter_snaptag_kiosk/core/data/datasources/local/heartbeat_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 2, 14, 0);

  HeartbeatNote note({
    Duration ago = const Duration(minutes: 1),
    bool eventRunning = true,
    String screen = kHeartbeatScreenCustomer,
    bool restartOnCrash = true,
  }) =>
      HeartbeatNote(
        at: now.subtract(ago),
        restartOnCrash: restartOnCrash,
        eventId: '11',
        eventRunning: eventRunning,
        screen: screen,
      );

  group('canRecoverEvent', () {
    test('손님을 받던 중 끊긴 쪽지는 되돌린다', () {
      expect(canRecoverEvent(note(), now: now), isTrue);
    });

    test('쪽지가 없으면 되돌리지 않는다', () {
      expect(canRecoverEvent(null, now: now), isFalse);
    });

    test('시각이 없는 쪽지는 되돌리지 않는다', () {
      expect(
        canRecoverEvent(const HeartbeatNote(eventRunning: true, screen: kHeartbeatScreenCustomer), now: now),
        isFalse,
      );
    });

    test('되살리지 말라고 적은 쪽지는 되돌리지 않는다', () {
      expect(canRecoverEvent(note(restartOnCrash: false), now: now), isFalse);
    });

    test('관리 화면에서 끊겼으면 사람이 앞에 있었으므로 되돌리지 않는다', () {
      expect(canRecoverEvent(note(screen: kHeartbeatScreenSetup), now: now), isFalse);
    });

    test('이벤트를 열지 않은 상태면 되돌리지 않는다', () {
      expect(canRecoverEvent(note(eventRunning: false), now: now), isFalse);
    });

    test('유통기한 15분이 지난 쪽지는 믿지 않는다', () {
      expect(canRecoverEvent(note(ago: const Duration(minutes: 15)), now: now), isFalse);
      expect(canRecoverEvent(note(ago: const Duration(minutes: 14, seconds: 59)), now: now), isTrue);
    });

    test('시계가 뒤로 간 쪽지는 얼마나 지났는지 셈할 수 없어 되돌리지 않는다', () {
      expect(canRecoverEvent(note(ago: const Duration(minutes: -1)), now: now), isFalse);
    });
  });

  group('screenForPath', () {
    test('손님 구간 경로는 모두 customer 다', () {
      for (final path in ['/kiosk', '/kiosk/home', '/kiosk/code-verification', '/kiosk/preview', '/kiosk/print-process']) {
        expect(screenForPath(path), kHeartbeatScreenCustomer, reason: path);
      }
    });

    test('관리 구간 경로는 모두 setup 이다', () {
      for (final path in ['/setup', '/setup/kiosk-info', '/setup/payment-history', '/setup/maintenance', '/setup/unit-test']) {
        expect(screenForPath(path), kHeartbeatScreenSetup, reason: path);
      }
    });

    test('경로를 모를 때는 setup 으로 본다', () {
      expect(screenForPath(''), kHeartbeatScreenSetup);
      expect(screenForPath('/'), kHeartbeatScreenSetup);
    });

    test('이름만 같은 경로를 손님 구간으로 오해하지 않는다', () {
      expect(screenForPath('/kiosk-info'), kHeartbeatScreenSetup);
      expect(screenForPath('/setup/kiosk-info'), kHeartbeatScreenSetup);
    });
  });

  group('HeartbeatNote.fromJson', () {
    test('앱이 쓴 그대로 읽어 낸다', () {
      final parsed = HeartbeatNote.fromJson({
        'at': '2026-09-02T13:59:00.000',
        'restartOnCrash': true,
        'eventId': '11',
        'eventRunning': true,
        'screen': 'customer',
      });

      expect(parsed!.at, DateTime(2026, 9, 2, 13, 59));
      expect(parsed.restartOnCrash, isTrue);
      expect(parsed.eventId, '11');
      expect(parsed.eventRunning, isTrue);
      expect(parsed.screen, kHeartbeatScreenCustomer);
      expect(canRecoverEvent(parsed, now: now), isTrue);
    });

    test('깨진 값은 null 로 두고 넘어간다', () {
      final parsed = HeartbeatNote.fromJson({
        'at': '어제',
        'restartOnCrash': 'true',
        'eventRunning': 1,
      });

      expect(parsed!.at, isNull);
      expect(parsed.restartOnCrash, isNull);
      expect(parsed.eventRunning, isNull);
      expect(canRecoverEvent(parsed, now: now), isFalse);
    });

    test('eventId 가 숫자로 와도 글로 읽는다', () {
      expect(HeartbeatNote.fromJson({'eventId': 11})!.eventId, '11');
    });

    test('인쇄 모드를 그대로 실어 나른다', () {
      expect(HeartbeatNote.fromJson({'printMode': 'double'})!.printMode, 'double');
      expect(HeartbeatNote.fromJson({'printMode': 'single'})!.printMode, 'single');
    });

    test('인쇄 모드가 없거나 글이 아니면 null 이다', () {
      expect(HeartbeatNote.fromJson({})!.printMode, isNull);
      expect(HeartbeatNote.fromJson({'printMode': 2})!.printMode, isNull);
    });
  });
}

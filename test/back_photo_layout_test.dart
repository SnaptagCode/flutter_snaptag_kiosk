import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreatePrintRequest (JKLI-214)', () {
    final base = CreatePrintRequest(
      kioskMachineId: 1,
      kioskEventId: 10,
      frontPhotoCardId: 100,
      backPhotoCardId: 200,
      kioskOrderId: 300,
    );

    test('출력 스타일은 qr 호출로 일원화 — print 요청에 backPhotoLayoutType을 보내지 않는다', () {
      expect(base.toJson().containsKey('backPhotoLayoutType'), isFalse);
    });
  });

  group('GetBackPhotoByQrRequest.imageType (JKLI-214)', () {
    GetBackPhotoByQrRequest request(String imageType) => GetBackPhotoByQrRequest(
          kioskEventId: 10,
          nominatedBackPhotoCardId: 7,
          imageType: imageType,
        );

    test('imageType이 대문자 그대로 직렬화된다', () {
      expect(request('ORIGIN').toJson()['imageType'], 'ORIGIN');
      expect(request('FORMATTED').toJson()['imageType'], 'FORMATTED');
    });

    test('기존 필드는 그대로 유지된다', () {
      final json = request('FORMATTED').toJson();
      expect(json['kioskEventId'], 10);
      expect(json['nominatedBackPhotoCardId'], 7);
    });
  });

  group('BackPhotoSelection.layoutType', () {
    test('기본값은 null(미선택) — 호출부에서 라벨(FORMATTED)로 보정한다', () {
      expect(BackPhotoSelection.fixed(0).layoutType, isNull);
      expect(BackPhotoSelection.custom().layoutType, isNull);
    });

    test('selectLayout은 type/fixedIndex를 유지하고 layoutType만 설정한다', () {
      final notifier = BackPhotoTypeNotifier();
      notifier.selectFixed(1);
      notifier.selectLayout(BackPhotoLayoutType.full);

      expect(notifier.state?.type, BackPhotoType.fixed);
      expect(notifier.state?.fixedIndex, 1);
      expect(notifier.state?.layoutType, BackPhotoLayoutType.full);
    });

    test('selectFixed 재선택 시 layoutType이 초기화된다', () {
      final notifier = BackPhotoTypeNotifier();
      notifier.selectFixed(0);
      notifier.selectLayout(BackPhotoLayoutType.full);
      notifier.selectFixed(1);

      expect(notifier.state?.layoutType, isNull);
    });

    test('imageType 매핑 — 라벨은 FORMATTED, 풀이미지는 ORIGIN', () {
      expect(BackPhotoLayoutType.labeled.imageType, 'FORMATTED');
      expect(BackPhotoLayoutType.full.imageType, 'ORIGIN');
    });

    test('미선택(null) 보정 결과는 FORMATTED', () {
      final selection = BackPhotoSelection.fixed(0);
      final layout = selection.layoutType ?? BackPhotoLayoutType.labeled;
      expect(layout.imageType, 'FORMATTED');
    });
  });
}

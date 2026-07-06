import 'package:flutter_snaptag_kiosk/core/data/models/response/kscat_device_response.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePaymentGateway implements PaymentGateway {
  int approveCallCount = 0;
  int checkCallCount = 0;
  int cancelCallCount = 0;

  int? lastCancelAmount;
  String? lastOriginalApprovalNo;
  String? lastOriginalApprovalDate;

  bool shouldThrow = false;

  PaymentResponse approveResponse = const PaymentResponse(res: '0000');
  KscatDeviceResponse checkResponse = const KscatDeviceResponse(res: '0000');
  PaymentResponse cancelResponse = const PaymentResponse(res: '0000');

  @override
  Future<PaymentResponse> approve({required int totalAmount}) async {
    approveCallCount++;
    if (shouldThrow) throw Exception('delegate approve failed');
    return approveResponse;
  }

  @override
  Future<KscatDeviceResponse> check() async {
    checkCallCount++;
    if (shouldThrow) throw Exception('delegate check failed');
    return checkResponse;
  }

  @override
  Future<PaymentResponse> cancel({
    required int totalAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  }) async {
    cancelCallCount++;
    lastCancelAmount = totalAmount;
    lastOriginalApprovalNo = originalApprovalNo;
    lastOriginalApprovalDate = originalApprovalDate;
    if (shouldThrow) throw Exception('delegate cancel failed');
    return cancelResponse;
  }
}

void main() {
  late FakePaymentGateway delegate;
  late DisabledPaymentGateway gateway;

  setUp(() {
    delegate = FakePaymentGateway();
    gateway = DisabledPaymentGateway(delegate);
  });

  group('DisabledPaymentGateway.approve — 승인은 차단된다', () {
    test('approve 호출 시 PaymentDisabledException을 던진다', () async {
      await expectLater(
        gateway.approve(totalAmount: 1000),
        throwsA(isA<PaymentDisabledException>()),
      );
    });

    test('approve는 위임 대상을 절대 호출하지 않는다 (0원 주문에 실제 승인이 붙는 것 방지)', () async {
      await expectLater(
        gateway.approve(totalAmount: 1000),
        throwsA(isA<PaymentDisabledException>()),
      );

      expect(delegate.approveCallCount, 0);
    });

    test('던져진 예외는 기본 메시지를 가진다', () async {
      try {
        await gateway.approve(totalAmount: 1000);
        fail('PaymentDisabledException이 던져져야 한다');
      } on PaymentDisabledException catch (e) {
        expect(e.message, '결제 기능이 비활성화되어 있습니다.');
      }
    });
  });

  group('DisabledPaymentGateway.check — 단말 확인은 위임된다', () {
    test('check는 위임 대상을 한 번 호출한다', () async {
      await gateway.check();

      expect(delegate.checkCallCount, 1);
    });

    test('check는 위임 대상의 응답을 그대로 반환한다', () async {
      delegate.checkResponse = const KscatDeviceResponse(res: '0000', reader: 'KSCAT-01');

      final response = await gateway.check();

      expect(response, same(delegate.checkResponse));
      expect(response.reader, 'KSCAT-01');
    });

    test('위임 대상이 던진 예외를 그대로 전파한다 (원격 환불 전 단말 점검 실패가 삼켜지면 안 됨)', () async {
      delegate.shouldThrow = true;

      await expectLater(gateway.check(), throwsA(isA<Exception>()));
      expect(delegate.checkCallCount, 1);
    });
  });

  group('DisabledPaymentGateway.cancel — 환불은 실제 단말로 위임된다', () {
    test('cancel은 전달받은 인자를 그대로 위임한다', () async {
      await gateway.cancel(
        totalAmount: 5000,
        originalApprovalNo: 'APPROVAL-123',
        originalApprovalDate: '260702',
      );

      expect(delegate.cancelCallCount, 1);
      expect(delegate.lastCancelAmount, 5000);
      expect(delegate.lastOriginalApprovalNo, 'APPROVAL-123');
      expect(delegate.lastOriginalApprovalDate, '260702');
    });

    test('cancel은 위임 대상의 응답을 그대로 반환한다', () async {
      delegate.cancelResponse = const PaymentResponse(res: '0000', approvalNo: 'CANCEL-999');

      final response = await gateway.cancel(
        totalAmount: 5000,
        originalApprovalNo: 'APPROVAL-123',
        originalApprovalDate: '260702',
      );

      expect(response, same(delegate.cancelResponse));
      expect(response.approvalNo, 'CANCEL-999');
    });

    test('위임 대상이 던진 예외를 그대로 전파한다', () async {
      delegate.shouldThrow = true;

      await expectLater(
        gateway.cancel(
          totalAmount: 5000,
          originalApprovalNo: 'APPROVAL-123',
          originalApprovalDate: '260702',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PaymentDisabledException', () {
    test('기본 메시지를 가진다', () {
      const exception = PaymentDisabledException();

      expect(exception.message, '결제 기능이 비활성화되어 있습니다.');
    });

    test('커스텀 메시지를 받을 수 있다', () {
      const exception = PaymentDisabledException('무료 모드입니다.');

      expect(exception.message, '무료 모드입니다.');
    });

    test('toString은 메시지를 반환한다', () {
      const exception = PaymentDisabledException('무료 모드입니다.');

      expect(exception.toString(), '무료 모드입니다.');
    });
  });
}

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_service_provider.g.dart';

@riverpod
class PaymentService extends _$PaymentService {
  @override
  Future<void> build() async {
    state = const AsyncValue.data(null);
  }

  /// 결제 프로세스 시작
  Future<void> startPayment() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // 1. 사전 검증
      _validatePaymentRequirements();

      // 2. 결제 진행
      await _processPayment();
    });
  }

  void _validatePaymentRequirements() {
    final settings = ref.read(storageServiceProvider).settings;
    final backPhoto = ref.read(backPhotoCardResponseInfoProvider);

    if (settings.kioskEventId == 0) {
      throw Exception(KioskErrorType.missingEventId);
    }
    if (settings.photoCardPrice <= 0) {
      throw Exception('Invalid photo card price');
    }
    if (backPhoto == null) {
      throw Exception('No back photo available');
    }
  }

  Future<void> _processPayment() async {
    // 1. 주문 생성
    await createOrder();

    // 2. 결제 승인
    await approvePayment();

    // 3. 주문 상태 업데이트
    await updateOrder(OrderStatus.completed);
  }

  Future<void> createOrder() async {
    final settings = ref.read(storageServiceProvider).settings;
    final backPhoto = ref.read(backPhotoCardResponseInfoProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final request = PostOrderRequest(
        kioskEventId: settings.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        photoAuthNumber: backPhoto.photoAuthNumber,
        amount: settings.photoCardPrice,
        paymentType: PaymentType.card,
      );

      await ref.read(kioskRepositoryProvider).createOrder(request);
    });
  }

  Future<void> approvePayment() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = ref.read(storageServiceProvider).settings;
      final value = taxCalculation(settings.photoCardPrice);

      final response = await ref.read(paymentRepositoryProvider).approve(
            totalAmount: value.total.toString(),
            supplyAmount: value.supplyAmount.toString(),
            tax: value.taxAmount.toString(),
          );

      ref.read(approvalInfoProvider.notifier).update(response);
    });
  }

  Future<void> cancelPayment() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final approvalInfo = ref.read(approvalInfoProvider);
      if (approvalInfo == null) {
        throw Exception('No payment approval info available');
      }

      final settings = ref.read(storageServiceProvider).settings;
      final value = taxCalculation(settings.photoCardPrice);

      await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: value.total.toString(),
            supplyAmount: value.supplyAmount.toString(),
            tax: value.taxAmount.toString(),
            originalApprovalNo: approvalInfo.approvalNo ?? '',
            originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
          );
    });
  }

  Future<void> updateOrder(OrderStatus status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = ref.read(storageServiceProvider).settings;
      final backPhoto = ref.read(backPhotoCardResponseInfoProvider);
      final approval = ref.read(approvalInfoProvider);

      final request = PatchOrderRequest(
        kioskEventId: settings.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        photoAuthNumber: backPhoto.photoAuthNumber,
        amount: settings.photoCardPrice,
        status: status,
        approvalNumber: approval?.approvalNo ?? '',
        purchaseAuthNumber: approval?.approvalNo ?? '',
        uniqueNumber: approval?.approvalNo ?? '',
        authSeqNumber: approval?.tradeUniqueNo ?? '',
        tradeNumber: approval?.tradeUniqueNo ?? '',
        detail: approval?.toJson() ?? {},
      );

      final response = await ref.read(kioskRepositoryProvider).updateOrderStatus(request);

      // OrderStatus.completed 상태일 때만 프린트 정보 업데이트
      if (status == OrderStatus.completed) {
        ref.read(backPhotoForPrintInfoProvider.notifier).update(response.backPhotoForPrint);
      }
    });
  }

  ({int total, int supplyAmount, int taxAmount}) taxCalculation(int total) {
    final supplyAmount = (total / 1.1).round();
    final taxAmount = total - supplyAmount;

    return (
      total: total,
      supplyAmount: supplyAmount,
      taxAmount: taxAmount,
    );
  }
}

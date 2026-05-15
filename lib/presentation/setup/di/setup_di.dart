import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/slack_log_provider.dart';
import 'package:flutter_snaptag_kiosk/domain/domain.dart';
import 'package:flutter_snaptag_kiosk/flavors.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/local/id_writer_service_impl.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/di/payment_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_di.g.dart';

@riverpod
ISetupRemoteDataSource setupRemoteDataSource(Ref ref) {
  return SetupRemoteDataSourceImpl(KioskApiClient(ref.watch(dioProvider(F.kioskBaseUrl))));
}

@riverpod
ISetupRepository setupRepository(Ref ref) {
  return SetupRepositoryImpl(ref.watch(setupRemoteDataSourceProvider));
}

@riverpod
StartKioskEventUseCase startKioskEventUseCase(Ref ref) {
  return StartKioskEventUseCase(
    ref.watch(setupRepositoryProvider),
    ref.watch(checkPaymentDeviceUseCaseProvider),
    ref.watch(slackLogServiceProvider),
    const IdWriterServiceImpl(),
  );
}

@riverpod
EndKioskApplicationUseCase endKioskApplicationUseCase(Ref ref) {
  return EndKioskApplicationUseCase(ref.watch(setupRepositoryProvider), ref.watch(slackLogServiceProvider));
}

@riverpod
IPaymentHistoryRemoteDataSource paymentHistoryRemoteDataSource(Ref ref) {
  return PaymentHistoryRemoteDataSourceImpl(KioskApiClient(ref.watch(dioProvider(F.kioskBaseUrl))));
}

@riverpod
IPaymentHistoryRepository paymentHistoryRepository(Ref ref) {
  return PaymentHistoryRepositoryImpl(ref.watch(paymentHistoryRemoteDataSourceProvider));
}

@riverpod
GetOrdersUseCase getOrdersUseCase(Ref ref) {
  return GetOrdersUseCase(ref.watch(paymentHistoryRepositoryProvider));
}

@riverpod
RefundOrderUseCase refundOrderUseCase(Ref ref) {
  final kioskInfo = ref.read(kioskInfoServiceProvider);
  return RefundOrderUseCase(
    ref.watch(paymentHistoryRepositoryProvider),
    ref.watch(paymentRepositoryProvider),
    ref.watch(slackLogServiceProvider),
    cardTerminalId: kioskInfo?.cardTerminalId,
  );
}

@riverpod
IEventPreviewRemoteDataSource eventPreviewRemoteDataSource(Ref ref) {
  return EventPreviewRemoteDataSourceImpl(KioskApiClient(ref.watch(dioProvider(F.kioskBaseUrl))));
}

@riverpod
IEventPreviewRepository eventPreviewRepository(Ref ref) {
  return EventPreviewRepositoryImpl(ref.watch(eventPreviewRemoteDataSourceProvider));
}

@riverpod
RefreshEventPreviewUseCase refreshEventPreviewUseCase(Ref ref) {
  return RefreshEventPreviewUseCase(ref.watch(eventPreviewRepositoryProvider), ref.watch(slackLogServiceProvider));
}

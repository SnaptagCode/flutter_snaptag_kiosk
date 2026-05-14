import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/event_preview_remote_data_source_impl.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/i_event_preview_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/i_payment_history_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/i_setup_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/payment_history_remote_data_source_impl.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/setup_remote_data_source_impl.dart';
import 'package:flutter_snaptag_kiosk/setup/data/repository_impl/event_preview_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/setup/data/repository_impl/payment_history_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/setup/data/repository_impl/setup_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_event_preview_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_history_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_setup_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/end_kiosk_application_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/get_orders_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/refund_order_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/refresh_event_preview_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/start_kiosk_event_use_case.dart';
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
  return StartKioskEventUseCase(ref);
}

@riverpod
EndKioskApplicationUseCase endKioskApplicationUseCase(Ref ref) {
  return EndKioskApplicationUseCase(ref);
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
  return RefundOrderUseCase(ref, ref.watch(paymentHistoryRepositoryProvider));
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
  return RefreshEventPreviewUseCase(ref, ref.watch(eventPreviewRepositoryProvider));
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/payment/data/datasource/i_payment_datasource.dart';
import 'package:flutter_snaptag_kiosk/payment/data/datasource/payment_datasource_impl.dart';
import 'package:flutter_snaptag_kiosk/payment/data/repository_impl/payment_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/repository/i_payment_repository.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/usecase/approve_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/usecase/cancel_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/usecase/check_payment_device_use_case.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/usecase/process_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/usecase/refund_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/usecase/error409_refund_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_di.g.dart';

@riverpod
IPaymentDatasource paymentDatasource(Ref ref) {
  return PaymentApiClient();
}

@riverpod
IPaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(
    ref.watch(paymentDatasourceProvider),
    ref,
  );
}

@riverpod
ApprovePaymentUseCase approvePaymentUseCase(Ref ref) {
  return ApprovePaymentUseCase(ref.watch(paymentRepositoryProvider));
}

@riverpod
CancelPaymentUseCase cancelPaymentUseCase(Ref ref) {
  return CancelPaymentUseCase(ref.watch(paymentRepositoryProvider));
}

@riverpod
CheckPaymentDeviceUseCase checkPaymentDeviceUseCase(Ref ref) {
  return CheckPaymentDeviceUseCase(ref.watch(paymentRepositoryProvider));
}

@riverpod
ProcessPaymentUseCase processPaymentUseCase(Ref ref) => ProcessPaymentUseCase(ref);

@riverpod
RefundPaymentUseCase refundPaymentUseCase(Ref ref) => RefundPaymentUseCase(ref);

@riverpod
Error409RefundUseCase error409RefundUseCase(Ref ref) => Error409RefundUseCase(ref);

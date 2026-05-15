import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/hardware/payment_terminal/i_payment_terminal_datasource.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/hardware/payment_terminal/payment_terminal_datasource.dart';
import 'package:flutter_snaptag_kiosk/data/repositories/kiosk_repository.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/slack_log_provider.dart';
import 'package:flutter_snaptag_kiosk/data/repositories/payment_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/order_update_service.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/approve_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/cancel_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/check_payment_device_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/error409_refund_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/process_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/refund_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_di.g.dart';

@riverpod
IPaymentTerminalDatasource paymentDatasource(Ref ref) {
  return PaymentTerminalDataSource();
}

@riverpod
IPaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(ref.watch(paymentDatasourceProvider));
}

@riverpod
ApprovePaymentUseCase approvePaymentUseCase(Ref ref) {
  final kioskInfo = ref.read(kioskInfoServiceProvider);
  return ApprovePaymentUseCase(
    ref.watch(paymentRepositoryProvider),
    kioskMachineId: kioskInfo?.kioskMachineId,
    cardTerminalId: kioskInfo?.cardTerminalId,
  );
}

@riverpod
CancelPaymentUseCase cancelPaymentUseCase(Ref ref) {
  final kioskInfo = ref.read(kioskInfoServiceProvider);
  return CancelPaymentUseCase(
    ref.watch(paymentRepositoryProvider),
    kioskMachineId: kioskInfo?.kioskMachineId,
    cardTerminalId: kioskInfo?.cardTerminalId,
  );
}

@riverpod
CheckPaymentDeviceUseCase checkPaymentDeviceUseCase(Ref ref) {
  final kioskInfo = ref.read(kioskInfoServiceProvider);
  return CheckPaymentDeviceUseCase(
    ref.watch(paymentRepositoryProvider),
    kioskMachineId: kioskInfo?.kioskMachineId,
    cardTerminalId: kioskInfo?.cardTerminalId,
  );
}

@riverpod
OrderUpdateService orderUpdateService(Ref ref) {
  return OrderUpdateService(
    ref.watch(kioskRepositoryProvider),
    ref.watch(slackLogServiceProvider),
  );
}

@riverpod
ProcessPaymentUseCase processPaymentUseCase(Ref ref) => ProcessPaymentUseCase(
      ref.watch(kioskRepositoryProvider),
      ref.watch(approvePaymentUseCaseProvider),
      ref.watch(orderUpdateServiceProvider),
      ref.watch(slackLogServiceProvider),
    );

@riverpod
RefundPaymentUseCase refundPaymentUseCase(Ref ref) => RefundPaymentUseCase(
      ref.watch(cancelPaymentUseCaseProvider),
      ref.watch(orderUpdateServiceProvider),
      ref.watch(slackLogServiceProvider),
    );

@riverpod
Error409RefundUseCase error409RefundUseCase(Ref ref) => Error409RefundUseCase(
      ref.watch(cancelPaymentUseCaseProvider),
      ref.watch(orderUpdateServiceProvider),
      ref.watch(slackLogServiceProvider),
    );

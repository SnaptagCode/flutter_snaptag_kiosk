import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/payment/data/datasource/i_payment_datasource.dart';
import 'package:flutter_snaptag_kiosk/payment/data/datasource/payment_datasource_impl.dart';
import 'package:flutter_snaptag_kiosk/payment/data/repository_impl/payment_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/repository/i_payment_repository.dart';
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

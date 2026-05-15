import 'package:flutter_snaptag_kiosk/domain/models/order/order_creation_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_order_info_notifier.g.dart';

@Riverpod(keepAlive: true)
class CreateOrderInfo extends _$CreateOrderInfo {
  @override
  OrderCreationResult? build() => null;

  void update(OrderCreationResult response) {
    state = response;
  }

  void reset() {
    state = null;
  }
}

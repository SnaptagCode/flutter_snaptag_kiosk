import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_order_info_state.g.dart';

@Riverpod(keepAlive: true)
class CreateOrderInfo extends _$CreateOrderInfo {
  @override
  CreateOrderResponse? build() => null;

  void update(CreateOrderResponse response) {
    state = response;
  }

  void reset() {
    state = null;
  }
}

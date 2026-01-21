import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_order_info_state.g.dart';

@Riverpod(keepAlive: true)
class UpdateOrderInfo extends _$UpdateOrderInfo {
  @override
  UpdateOrderResponse? build() => null;

  void update(UpdateOrderResponse response) {
    state = response;
  }

  void reset() {
    state = null;
  }
}

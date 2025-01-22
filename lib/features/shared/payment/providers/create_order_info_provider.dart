import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_order_info_provider.g.dart';

@Riverpod(keepAlive: true)
class CreateOrderInfo extends _$CreateOrderInfo {
  @override
  PostOrderResponse? build() => null;

  void update(PostOrderResponse response) {
    state = response;
  }
}

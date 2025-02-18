import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_history_provider.g.dart';

@riverpod
class OrdersPage extends _$OrdersPage {
  final int _pageSize = 20;
  int get kioskEventId => ref.watch(storageServiceProvider).settings.kioskEventId;
  @override
  Future<OrderListResponse> build({int page = 1}) async {
    final OrderListResponse response = await ref.read(kioskRepositoryProvider).getOrders(GetOrdersRequest(
          pageSize: _pageSize,
          currentPage: page,
        ));
    logger.i('response: $response');
    return response;
  }

  Future<void> goToPage(int newPage) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(kioskRepositoryProvider).getOrders(GetOrdersRequest(
          pageSize: _pageSize,
          currentPage: newPage,
        )));
  }
}

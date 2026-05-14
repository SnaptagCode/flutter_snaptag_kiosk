import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/get_orders_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/refund_order_use_case.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/di/setup_di.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/payment_history/notifier/payment_history_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/payment_history/notifier/payment_history_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_history_notifier.g.dart';

@riverpod
class PaymentHistoryNotifier extends _$PaymentHistoryNotifier {
  late final GetOrdersUseCase _getOrdersUseCase;
  late final RefundOrderUseCase _refundOrderUseCase;

  int _currentPage = 1;
  OrderEntity? _pendingRefundOrder;
  static const int _pageSize = 15;

  @override
  PaymentHistoryState build() {
    _getOrdersUseCase = ref.watch(getOrdersUseCaseProvider);
    _refundOrderUseCase = ref.watch(refundOrderUseCaseProvider);
    _loadOrders();
    return const PaymentHistoryState.loading();
  }

  Future<void> onAction(PaymentHistoryAction action) async {
    switch (action) {
      case PaymentHistoryActionGoToPage(:final page):
        await _loadOrders(page: page);

      case PaymentHistoryActionRequestRefund(:final order):
        final orders = _currentOrders;
        if (orders != null) {
          _pendingRefundOrder = order;
          state = PaymentHistoryState.awaitingRefundConfirmation(orders: orders, pendingOrder: order);
        }

      case PaymentHistoryActionConfirmRefund():
        await _executeRefund();

      case PaymentHistoryActionCancelRefund():
        final orders = _currentOrders;
        state = orders != null ? PaymentHistoryState.loaded(orders) : const PaymentHistoryState.loading();

      case PaymentHistoryActionAcknowledgeResult():
        await _loadOrders(page: _currentPage);
    }
  }

  OrderListResponse? get _currentOrders => switch (state) {
        PaymentHistoryStateLoaded(:final orders) => orders,
        PaymentHistoryStateAwaitingRefundConfirmation(:final orders) => orders,
        PaymentHistoryStateRefundSuccess(:final orders) => orders,
        PaymentHistoryStateFailure(:final orders) => orders,
        _ => null,
      };

  Future<void> _loadOrders({int page = 1}) async {
    state = const PaymentHistoryState.loading();
    try {
      final kioskMachineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      final orders = await _getOrdersUseCase(GetOrdersRequest(
        pageSize: _pageSize,
        currentPage: page,
        kioskMachineId: kioskMachineId,
      ));
      _currentPage = page;
      state = PaymentHistoryState.loaded(orders);
    } catch (e) {
      state = PaymentHistoryState.failure(failure: PaymentHistoryFailure.loadFailed(e));
    }
  }

  Future<void> _executeRefund() async {
    final order = _pendingRefundOrder;
    if (order == null) return;
    final orders = _currentOrders;
    state = const PaymentHistoryState.loading();
    try {
      await _refundOrderUseCase.execute(order);
      final freshOrders = await _getOrdersUseCase(GetOrdersRequest(
        pageSize: _pageSize,
        currentPage: _currentPage,
        kioskMachineId: ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0,
      ));
      _pendingRefundOrder = null;
      state = PaymentHistoryState.refundSuccess(freshOrders);
    } catch (e) {
      _pendingRefundOrder = null;
      state = PaymentHistoryState.failure(failure: PaymentHistoryFailure.refundFailed(e), orders: orders);
    }
  }
}

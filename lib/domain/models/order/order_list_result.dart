import 'package:flutter_snaptag_kiosk/domain/models/order/order_data.dart';

class PagingInfo {
  final int totalCount;
  final int pageSize;
  final int currentPage;
  final bool canNext;

  const PagingInfo({
    required this.totalCount,
    required this.pageSize,
    required this.currentPage,
    required this.canNext,
  });
}

class OrderListResult {
  final List<OrderData> list;
  final PagingInfo paging;

  const OrderListResult({
    required this.list,
    required this.paging,
  });
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/domain/models/enums/order_status.dart';
import 'package:flutter_snaptag_kiosk/domain/models/enums/printed_status.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_data.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/payment_history/notifier/payment_history_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/payment_history/screen/payment_history_screen_state.dart';
import 'package:flutter_svg/svg.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final PaymentHistoryScreenState state;
  final void Function(PaymentHistoryAction) onAction;
  final VoidCallback onBack;
  final VoidCallback onHome;

  const PaymentHistoryScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.onBack,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.only(left: 30.w),
          icon: SvgPicture.asset(SnaptagSvg.arrowBack),
          onPressed: onBack,
        ),
        title: const Text('출력 내역'),
        actions: [
          IconButton(
            padding: EdgeInsets.only(left: 30.w),
            icon: SvgPicture.asset(SnaptagSvg.home),
            onPressed: onHome,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.hasLoadError) {
      return GeneralErrorWidget(
        exception: Exception('주문 내역을 불러오지 못했습니다.'),
        onRetry: () => onAction(const PaymentHistoryAction.goToPage(1)),
      );
    }

    final orders = state.orders;
    if (orders == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 130.w),
        SizedBox(
          width: 438.w,
          child: const _DateWidget(),
        ),
        SizedBox(height: 60.w),
        DataTable(
          columnSpacing: 15.0,
          horizontalMargin: 0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          headingTextStyle: TextStyle(color: const Color(0xFF757575), fontSize: 18.sp),
          headingRowColor: WidgetStateColor.resolveWith((_) => const Color(0xFFF6F7F8)),
          dataTextStyle: TextStyle(color: const Color(0xFF414448), fontSize: 16.sp),
          columns: _columns,
          rows: orders.list.map((order) => _buildRow(context, order)).toList(),
        ),
        _PaginationControls(
          currentPage: orders.paging.currentPage,
          totalPages: (orders.paging.totalCount / orders.paging.pageSize).ceil(),
          onPageChanged: (page) => onAction(PaymentHistoryAction.goToPage(page)),
        ),
      ],
    );
  }

  List<DataColumn> get _columns => const [
        DataColumn(label: Text('일자'), headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('이벤트명'), headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('결제 금액'), headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('결제 상태'), headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('환불 상태'), headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('출력 상태'), headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('인증번호'), headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('결제 승인번호'), headingRowAlignment: MainAxisAlignment.center),
      ];

  DataRow _buildRow(BuildContext context, OrderData order) {
    return DataRow(
      color: WidgetStateColor.resolveWith((_) => Colors.white),
      cells: [
        DataCell(Center(
          child: Text(order.completedAt != null
              ? DateFormat('yyyy.MM.dd HH:mm').format(order.completedAt!)
              : ''),
        )),
        DataCell(Center(
          child: Text(
            order.eventName.length > 20 ? '${order.eventName.substring(0, 20)}...' : order.eventName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Center(child: Text(NumberFormat('#,###').format(order.amount.toInt())))),
        DataCell(Center(child: Text(_orderStateLabel(order.orderStatus)))),
        DataCell(Center(child: _refundCell(context, order))),
        DataCell(Center(child: Text(_isPrinted(order.printedStatus) ? 'O' : 'X'))),
        DataCell(Center(child: Text(order.photoAuthNumber))),
        DataCell(Center(child: Text(order.paymentAuthNumber ?? ''))),
      ],
    );
  }

  bool _isPrinted(PrintedStatus? status) {
    if (status == null) return false;
    return switch (status) {
      PrintedStatus.completed ||
      PrintedStatus.refunded_after_printed ||
      PrintedStatus.refunded_failed_after_printed =>
        true,
      _ => false,
    };
  }

  String _orderStateLabel(OrderStatus status) => switch (status) {
        OrderStatus.pending => '결제 대기',
        OrderStatus.failed => '결제 실패',
        _ => '결제 완료',
      };

  Widget _refundCell(BuildContext context, OrderData order) {
    switch (order.orderStatus) {
      case OrderStatus.pending:
      case OrderStatus.failed:
        return TextButton(
          onPressed: null,
          child: Text('-', style: TextStyle(color: const Color(0xFF414448), fontSize: 16.sp)),
        );
      default:
        return switch (order.printedStatus) {
          PrintedStatus.refunded_after_printed || PrintedStatus.refunded_before_printed => TextButton(
              onPressed: null,
              child: Text('환불 완료', style: TextStyle(color: const Color(0xFF414448), fontSize: 16.sp)),
            ),
          PrintedStatus.refunded_failed_after_printed ||
          PrintedStatus.refunded_failed_before_printed =>
            TextButton(
              onPressed: () => onAction(PaymentHistoryAction.requestRefund(order)),
              child: Container(
                decoration:
                    const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFFF333F)))),
                child: Text('환불 실패', style: TextStyle(color: const Color(0xFFFF333F), fontSize: 16.sp)),
              ),
            ),
          _ => TextButton(
              onPressed: () => onAction(PaymentHistoryAction.requestRefund(order)),
              child: Container(
                decoration:
                    const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF9D9D9D)))),
                child: Text('환불', style: TextStyle(color: const Color(0xFF9D9D9D), fontSize: 16.sp)),
              ),
            ),
        };
    }
  }
}

class _DateWidget extends StatelessWidget {
  const _DateWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(const Duration(days: 14))),
          style: TextStyle(color: const Color(0xFF1C1C1C), fontSize: 32.sp, fontWeight: FontWeight.w700),
        ),
        Text('-',
            style: TextStyle(color: const Color(0xFF1C1C1C), fontSize: 32.sp, fontWeight: FontWeight.w700)),
        Text(
          DateFormat('yyyy.MM.dd').format(DateTime.now()),
          style: TextStyle(color: const Color(0xFF1C1C1C), fontSize: 32.sp, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> pageButtons() {
      final startPage = (currentPage - 5).clamp(1, totalPages > 10 ? totalPages - 9 : 1);
      final endPage = (startPage + 9).clamp(startPage, totalPages);
      return [
        for (int i = startPage; i <= endPage; i++)
          ActionChip(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            labelPadding: EdgeInsets.zero,
            label: Text(i.toString(),
                style: TextStyle(color: i == currentPage ? Colors.white : Colors.black, fontSize: 14)),
            backgroundColor: i == currentPage ? const Color(0xFFA671EA) : const Color(0xFFF2F2F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: Colors.transparent),
            ),
            onPressed: () => onPageChanged(i),
          ),
      ];
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
                onTap: currentPage > 1 ? () => onPageChanged(1) : null,
                child: const Icon(Icons.keyboard_double_arrow_left_sharp)),
            const SizedBox(width: 8),
            InkWell(
                onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                child: const Icon(Icons.chevron_left)),
            const SizedBox(width: 8),
            ...pageButtons(),
            const SizedBox(width: 8),
            InkWell(
                onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                child: const Icon(Icons.chevron_right)),
            const SizedBox(width: 8),
            InkWell(
                onTap: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
                child: const Icon(Icons.keyboard_double_arrow_right_sharp)),
          ],
        ),
      ),
    );
  }
}

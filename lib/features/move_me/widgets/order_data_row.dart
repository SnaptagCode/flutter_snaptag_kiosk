import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_data_row.g.dart';

@riverpod
class OrderDataRow extends _$OrderDataRow {
  @override
  DataRow build(OrderEntity order) {
    return DataRow(
      color: WidgetStateColor.resolveWith((states) => Colors.white),
      cells: [
        DataCell(
          Center(
            child: Text(
              order.completedAt != null
                  ? DateFormat('yyyy.MM.dd hh:mm').format(
                      order.completedAt!,
                    )
                  : '',
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              order.eventName.length > 20 ? '${order.eventName.substring(0, 20)}...' : order.eventName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Center(child: Text(NumberFormat('#,###').format(order.amount.toInt()))),
        ),
        DataCell(
          Center(child: Text(_getOrderState(order.orderStatus))),
        ),
        DataCell(
          Center(
            child: _getRefundStatusText(order),
          ),
        ),
        DataCell(
          Center(child: Text(isPrinted(order.printedStatus) ? 'O' : 'X')),
        ),
        DataCell(
          Center(child: Text(order.photoAuthNumber)),
        ),
        DataCell(
          Center(child: Text(order.paymentAuthNumber ?? '')),
        ),
      ],
    );
  }

  bool isPrinted(PrintedStatus printed) {
    switch (printed) {
      case PrintedStatus.pending:
      case PrintedStatus.started:
      case PrintedStatus.failed:
      case PrintedStatus.refunded_before_printed:
      case PrintedStatus.refunded_failed_before_printed:
        return false;
      case PrintedStatus.completed:
      case PrintedStatus.refunded_after_printed:
      case PrintedStatus.refunded_failed_after_printed:
        return true;
    }
  }

  String _getOrderState(OrderStatus order) {
    switch (order) {
      case OrderStatus.pending:
        return '결제 대기';
      case OrderStatus.failed:
        return '결제 실패';
      case OrderStatus.completed:
      case OrderStatus.refunded:
      case OrderStatus.refunded_failed:
      case OrderStatus.refunded_failed_before_printed:
        return '결제 완료';
    }
  }

  TextButton _getRefundStatusText(OrderEntity order) {
    switch (order.orderStatus) {
      case OrderStatus.pending:
      case OrderStatus.failed:
        return TextButton(
          onPressed: null,
          child: Text(
            '-',
            style: TextStyle(
              color: Color(0xFF414448),
              fontSize: 16.sp,
            ),
          ),
        );
      default:
        switch (order.printedStatus) {
          case PrintedStatus.refunded_after_printed:
          case PrintedStatus.refunded_before_printed:
            return TextButton(
              onPressed: null,
              child: Text(
                '환불 완료',
                style: TextStyle(
                  color: Color(0xFF414448),
                  fontSize: 16.sp,
                ),
              ),
            );
          case PrintedStatus.refunded_failed_after_printed:
          case PrintedStatus.refunded_failed_before_printed:
            return TextButton(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFFF333F),
                    ),
                  ),
                ),
                child: Text(
                  '환불 실패',
                  style: TextStyle(
                    color: Color(0xFFFF333F),
                    fontSize: 16.sp,
                  ),
                ),
              ),
              onPressed: () async {
                await ref.read(setupRefundProcessProvider.notifier).startRefund(order);
              },
            );
          default:
            return TextButton(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                ),
                child: Text(
                  '환불',
                  style: TextStyle(
                    color: Color(0xFF9D9D9D),
                    fontSize: 16.sp,
                  ),
                ),
              ),
              onPressed: () async {
                await ref.read(setupRefundProcessProvider.notifier).startRefund(order);
              },
            );
        }
    }
  }
}

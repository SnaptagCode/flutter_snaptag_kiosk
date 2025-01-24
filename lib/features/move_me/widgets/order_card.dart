import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class OrderCard extends ConsumerWidget {
  final OrderEntity order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref.read(setupRefundProcessProvider.notifier).startRefund(order);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${order.orderId}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kiosk Machine ID: ${order.kioskMachineId}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Photo Auth Number: ${order.photoAuthNumber}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Payment Auth Number: ${order.paymentAuthNumber}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Amount: \$${order.amount.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Completed At: ${order.completedAt}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Refunded At: ${order.refundedAt}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Order Status: ${order.orderStatus}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Printed Status: ${order.printedStatus}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

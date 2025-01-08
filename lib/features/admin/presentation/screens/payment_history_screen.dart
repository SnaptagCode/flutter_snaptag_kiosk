import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const OrderListPage();
  }
}

class OrderListPage extends ConsumerWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersPage = ref.watch(ordersPageProvider());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Catalog'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ordersPage.when(
        data: (response) => Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(ordersPageProvider().future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: response.list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => OrderCard(
                    order: response.list[index],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: PaginationControls(
                currentPage: response.paging.currentPage,
                totalPages: (response.paging.totalCount / response.paging.pageSize).ceil(),
                onPageChanged: (newPage) {
                  ref.read(ordersPageProvider().notifier).goToPage(newPage);
                },
              ),
            ),
          ],
        ),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading orders...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading orders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(ordersPageProvider()),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderEntity order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected Order ID: ${order.orderId}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
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

// PaginationControls 위젯은 이전과 동일
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First page button
            FilledButton.tonal(
              onPressed: currentPage > 1 ? () => onPageChanged(1) : null, // 1부터 시작
              child: const Icon(Icons.first_page),
            ),
            const SizedBox(width: 8),
            // Previous page button
            FilledButton.tonal(
              onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null, // 1부터 시작
              child: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 16),
            // Page indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Page $currentPage of $totalPages', // 1부터 시작
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Next page button
            FilledButton.tonal(
              onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              child: const Icon(Icons.chevron_right),
            ),
            const SizedBox(width: 8),
            // Last page button
            FilledButton.tonal(
              onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null, // 1부터 시작
              child: const Icon(Icons.last_page),
            ),
          ],
        ),
      ),
    );
  }
}

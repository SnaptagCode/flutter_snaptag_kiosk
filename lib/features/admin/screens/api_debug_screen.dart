import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class ApiDebugScreen extends ConsumerWidget {
  const ApiDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printStatusState = ref.watch(updatePrintStatusProvider);
    final backPhotoCardState = ref.watch(backPhotoCardProvider);
    final createOrderState = ref.watch(createOrderProvider);
    final updateOrderState = ref.watch(updateOrderProvider);

    Widget buildApiSection({
      required String title,
      required ApiResponse state,
      required VoidCallback onTest,
    }) {
      return Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                  ),
                  ElevatedButton(
                    onPressed: state.isLoading ? null : onTest,
                    child: state.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Test'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Error: ${state.error}',
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              if (state.data != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Response:',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.data.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildApiSection(
              title: 'Get Back Photo Card',
              state: backPhotoCardState,
              onTest: () => ref.read(backPhotoCardProvider.notifier).fetch(1, '1234'),
            ),
            buildApiSection(
              title: 'Create Order',
              state: createOrderState,
              onTest: () => ref.read(createOrderProvider.notifier).create({}),
            ),
            buildApiSection(
              title: 'Update Print Status',
              state: printStatusState,
              onTest: () => ref.read(updatePrintStatusProvider.notifier).update(
                    kioskMachineId: 1,
                    kioskEventId: 1,
                    frontPhotoCardId: 1,
                    photoAuthNumber: '1234',
                    status: PrintStatus.completed,
                  ),
            ),
            buildApiSection(
              title: 'Update Order',
              state: updateOrderState,
              onTest: () => ref.read(updateOrderProvider.notifier).update(
                    1,
                    OrderStatus.completed,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

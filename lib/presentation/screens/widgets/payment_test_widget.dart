import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/providers/states/payment_response_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_test_widget.g.dart';

@riverpod
class PaymentTestState extends _$PaymentTestState {
  @override
  bool build() {
    return false; // false = approval, true = refund
  }

  void toggleMode() {
    state = !state;
  }
}

class PaymentTestWidget extends ConsumerWidget {
  const PaymentTestWidget({super.key});
  Future<void> _approvePayment(BuildContext context, WidgetRef ref, String amount) async {
    try {
      if (amount.isEmpty) {
        throw Exception('금액을 입력해주세요');
      }

      final response = await ref.read(paymentRepositoryProvider).approve(
            totalAmount: int.parse(amount),
          );

      ref.read(paymentResponseStateProvider.notifier).update(response);

      // 성공 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제가 성공적으로 처리되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelPayment(
    BuildContext context,
    WidgetRef ref, {
    required String amount,
    required String approvalNo,
    required String approvalDate,
  }) async {
    try {
      if (approvalNo.isEmpty || approvalDate.isEmpty) {
        throw Exception('승인번호와 승인일자를 입력해주세요');
      }

      final response = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: int.parse(amount),
            originalApprovalNo: approvalNo,
            originalApprovalDate: approvalDate,
          );

      if (response.isSuccess) {
        ref.read(paymentResponseStateProvider.notifier).reset();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('환불이 성공적으로 처리되었습니다')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('환불 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRefundMode = ref.watch(paymentTestStateProvider);
    final approvalInfo = ref.watch(paymentResponseStateProvider);

    final amountController = TextEditingController();
    final approvalNoController = TextEditingController();
    final approvalDateController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text('결제'),
                          selected: !isRefundMode,
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(paymentTestStateProvider.notifier).toggleMode();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('환불'),
                          selected: isRefundMode,
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(paymentTestStateProvider.notifier).toggleMode();
                            }
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (isRefundMode) {
                          _cancelPayment(
                            context,
                            ref,
                            amount: amountController.text,
                            approvalNo: approvalNoController.text,
                            approvalDate: approvalDateController.text,
                          );
                        } else {
                          _approvePayment(
                            context,
                            ref,
                            amountController.text,
                          );
                        }
                      },
                      child: Text('Run'),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: '금액',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (isRefundMode) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: approvalNoController,
                    decoration: const InputDecoration(
                      labelText: '승인번호',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: approvalDateController,
                    decoration: const InputDecoration(
                      labelText: '승인일자 (YYMMDD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const Divider(),
              ],
            ),
          ),
        ),
        if (approvalInfo != null) ...[
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('승인 정보'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(approvalInfo.toString())],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

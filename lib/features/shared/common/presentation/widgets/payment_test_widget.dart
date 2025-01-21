import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_test_widget.freezed.dart';
part 'payment_test_widget.g.dart';

@freezed
class PaymentTestCase with _$PaymentTestCase {
  const factory PaymentTestCase({
    required String name,
    required bool isRefund,
    @Default('') String approvalNo,
    @Default('') String approvalDate,
    required int amount,
  }) = _PaymentTestCase;

  factory PaymentTestCase.fromJson(Map<String, dynamic> json) => _$PaymentTestCaseFromJson(json);
}

final defaultTestCases = [
  PaymentTestCase(
    name: '일반 결제',
    isRefund: false,
    amount: 1000,
  ),
  PaymentTestCase(
    name: '취소 결제',
    isRefund: true,
    amount: 1000,
  ),
];

@riverpod
class PaymentTestState extends _$PaymentTestState {
  @override
  PaymentTestCase build() {
    return defaultTestCases[0];
  }

  void toggleTestCase() {
    final currentIndex = defaultTestCases.indexOf(state);
    final nextIndex = (currentIndex + 1) % defaultTestCases.length;
    state = defaultTestCases[nextIndex];
  }
}

class PaymentTestWidget extends ConsumerWidget {
  const PaymentTestWidget({super.key});

  Future<void> _approvePayment(BuildContext context, WidgetRef ref) async {
    final testCase = ref.read(paymentTestStateProvider);

    final response = await ref.read(paymentRepositoryProvider).approve(
          totalAmount: testCase.amount.toString(),
          tax: '91',
          supplyAmount: '913',
        );

    ref.read(approvalInfoProvider.notifier).update(response);
  }

  Future<void> _cancelPayment(BuildContext context, WidgetRef ref) async {
    final testCase = ref.read(paymentTestStateProvider);
    final approvalInfo = ref.read(approvalInfoProvider);

    try {
      final response = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: testCase.amount.toString(),
            tax: '91',
            supplyAmount: '913',
            originalApprovalNo: approvalInfo?.approvalNo ?? '',
            originalApprovalDate: approvalInfo?.tradeTime?.substring(0, 6) ?? '',
          );

      // 취소 성공 시 승인 정보 초기화
      if (response.isSuccess) {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testCase = ref.watch(paymentTestStateProvider);
    final approvalInfo = ref.watch(approvalInfoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTestCaseInfo(testCase, approvalInfo),
        const SizedBox(height: 24),
        _buildActionButtons(context, ref, testCase),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTestCaseInfo(PaymentTestCase testCase, PaymentResponse? approvalInfo) {
    return Card(
      child: ListTile(
        title: Text(testCase.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '금액: ${testCase.amount}원',
            ),
            if (approvalInfo != null) ...[
              Text('승인번호: ${approvalInfo.approvalNo}'),
              Text('승인일자: ${approvalInfo.tradeTime}'),
              Text('거래고유번호: ${approvalInfo.tradeUniqueNo}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, PaymentTestCase testCase) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _approvePayment(context, ref),
          child: const Text('승인'),
        ),
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: '테스트 케이스 변경',
          onPressed: () => ref.read(paymentTestStateProvider.notifier).toggleTestCase(),
        ),
        ElevatedButton(
          onPressed: testCase.isRefund ? () => _cancelPayment(context, ref) : null,
          child: const Text('취소'),
        ),
      ],
    );
  }

  Widget _buildRequestInfo(String title, String content) {
    final displayContent = formatForDisplay(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(displayContent),
          ),
        ),
      ],
    );
  }

  String formatForDisplay(String request) {
    return request.split('').map((char) {
      switch (char.codeUnitAt(0)) {
        case 0x02: // STX
          return '[STX]';
        case 0x03: // ETX
          return '[ETX]';
        case 0x0D: // CR
          return '[CR]';
        case 0x1C: // FS
          return '[FS]';
        default:
          return char;
      }
    }).join();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_request_test_screen.freezed.dart';
part 'payment_request_test_screen.g.dart';

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
    amount: 10000,
  ),
  PaymentTestCase(
    name: '취소 결제',
    isRefund: true,
    approvalNo: '12345678',
    approvalDate: '240108',
    amount: 10000,
  ),
];

@riverpod
class TestCaseState extends _$TestCaseState {
  @override
  PaymentTestCase build() {
    return defaultTestCases[0];
  }

  void selectPredefinedCase(int index) {
    if (index >= 0 && index < defaultTestCases.length) {
      state = defaultTestCases[index];
    }
  }

  void toggleTestCase() {
    final currentIndex = defaultTestCases.indexOf(state);
    final nextIndex = (currentIndex + 1) % defaultTestCases.length;
    state = defaultTestCases[nextIndex];
  }
}

class PaymentRequestTestScreen extends ConsumerWidget {
  const PaymentRequestTestScreen({super.key});

  Future<void> _approvePayment(BuildContext context, WidgetRef ref) async {
    final testCase = ref.read(testCaseStateProvider);
    try {
      final request = PaymentRequest.approval(
        totalAmount: testCase.amount.toString(),
        tax: '91', // 예시 값
        supplyAmount: '913', // 예시 값
      );
      ref.read(paymentRequestProvider.notifier).state = request.serialize();

      final response = await ref.read(paymentRepositoryProvider).approve(
            totalAmount: testCase.amount.toString(),
            tax: '91', // 예시 값
            supplyAmount: '913', // 예시 값
          );
      ref.read(paymentResponseProvider.notifier).state = response.toString();
      ref.read(paymentErrorProvider.notifier).state = null;
    } on PaymentException catch (e) {
      ref.read(paymentErrorProvider.notifier).state = e.toString();
    }
  }

  Future<void> _cancelPayment(BuildContext context, WidgetRef ref) async {
    final testCase = ref.read(testCaseStateProvider);
    try {
      final request = PaymentRequest.cancel(
        totalAmount: testCase.amount.toString(),
        tax: '91', // 예시 값
        supplyAmount: '913', // 예시 값
        originalApprovalNo: testCase.approvalNo,
        originalApprovalDate: testCase.approvalDate,
      );
      ref.read(paymentRequestProvider.notifier).state = request.serialize();

      final response = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: testCase.amount.toString(),
            tax: '91', // 예시 값
            supplyAmount: '913', // 예시 값
            originalApprovalNo: testCase.approvalNo,
            originalApprovalDate: testCase.approvalDate,
          );
      ref.read(paymentResponseProvider.notifier).state = response.toString();
      ref.read(paymentErrorProvider.notifier).state = null;
    } catch (e) {
      ref.read(paymentErrorProvider.notifier).state = e.toString();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testCase = ref.watch(testCaseStateProvider);
    final notifier = ref.read(testCaseStateProvider.notifier);

    final paymentRequest = ref.watch(paymentRequestProvider);
    final paymentResponse = ref.watch(paymentResponseProvider);
    final paymentError = ref.watch(paymentErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Request Test - ${testCase.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: '테스트 케이스 변경',
            onPressed: () => notifier.toggleTestCase(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestCaseInfo(testCase),
            const SizedBox(height: 24),
            _buildActionButtons(context, ref, testCase),
            const SizedBox(height: 24),
            if (paymentRequest != null) _buildRequestInfo('Request:', paymentRequest),
            if (paymentResponse != null) _buildRequestInfo('Response:', paymentResponse),
            if (paymentError != null) _buildRequestInfo('Error:', paymentError),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCaseInfo(PaymentTestCase testCase) {
    return Card(
      child: ListTile(
        title: Text(testCase.name),
        subtitle: Text(
          '금액: ${testCase.amount}원${testCase.isRefund ? ' / 승인번호: ${testCase.approvalNo} / 승인일자: ${testCase.approvalDate}' : ''}',
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

final paymentRequestProvider = StateProvider<String?>((ref) => null);
final paymentResponseProvider = StateProvider<String?>((ref) => null);
final paymentErrorProvider = StateProvider<String?>((ref) => null);

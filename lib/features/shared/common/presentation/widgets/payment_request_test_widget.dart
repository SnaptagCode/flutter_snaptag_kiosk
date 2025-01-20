import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_request_test_widget.freezed.dart';
part 'payment_request_test_widget.g.dart';

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

@riverpod
class ApprovalInfo extends _$ApprovalInfo {
  @override
  PaymentResponse? build() {
    return null;
  }

  void setInfo(PaymentResponse response) {
    state = response;
  }
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
    approvalNo: '12345678',
    approvalDate: '240108',
    amount: 1000,
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

class PaymentRequestTestWidget extends ConsumerWidget {
  const PaymentRequestTestWidget({super.key});

  Future<void> _approvePayment(BuildContext context, WidgetRef ref) async {
    final testCase = ref.read(testCaseStateProvider);
    try {
      final request = PaymentRequest.approval(
        totalAmount: testCase.amount.toString(),
        tax: '91',
        supplyAmount: '913',
      );
      ref.read(paymentRequestProvider.notifier).state = request.serialize();

      final response = await ref.read(paymentRepositoryProvider).approve(
            totalAmount: testCase.amount.toString(),
            tax: '91',
            supplyAmount: '913',
          );
      // 응답 저장
      ref.read(paymentResponseProvider.notifier).state = response.toString();
      // 승인 정보 저장
      ref.read(approvalInfoProvider.notifier).setInfo(response);
      ref.read(paymentErrorProvider.notifier).state = null;
    } on PaymentException catch (e) {
      ref.read(paymentErrorProvider.notifier).state = e.toString();
    }
  }

  Future<void> _cancelPayment(BuildContext context, WidgetRef ref) async {
    final testCase = ref.read(testCaseStateProvider);
    final approvalInfo = ref.read(approvalInfoProvider);

    if (approvalInfo == null) {
      ref.read(paymentErrorProvider.notifier).state = '승인 정보가 없습니다';
      return;
    }

    try {
      final request = PaymentRequest.cancel(
        totalAmount: testCase.amount.toString(),
        tax: '91',
        supplyAmount: '913',
        originalApprovalNo: approvalInfo.approvalNo ?? '',
        originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '', // YYMMDD 형식으로 추출
      );
      ref.read(paymentRequestProvider.notifier).state = request.serialize();

      final response = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: testCase.amount.toString(),
            tax: '91',
            supplyAmount: '913',
            originalApprovalNo: approvalInfo.approvalNo ?? '',
            originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
          );
      ref.read(paymentResponseProvider.notifier).state = response.toString();
      ref.read(paymentErrorProvider.notifier).state = null;

      // 취소 성공 시 승인 정보 초기화
      if (response.isSuccess) {}
    } catch (e) {
      ref.read(paymentErrorProvider.notifier).state = e.toString();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testCase = ref.watch(testCaseStateProvider);
    final approvalInfo = ref.watch(approvalInfoProvider);
    final paymentRequest = ref.watch(paymentRequestProvider);
    final paymentResponse = ref.watch(paymentResponseProvider);
    final paymentError = ref.watch(paymentErrorProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTestCaseInfo(testCase, approvalInfo),
        const SizedBox(height: 24),
        _buildActionButtons(context, ref, testCase),
        const SizedBox(height: 24),
        if (paymentRequest != null) _buildRequestInfo('Request:', paymentRequest),
        if (paymentResponse != null) _buildRequestInfo('Response:', paymentResponse),
        if (paymentError != null) _buildRequestInfo('Error:', paymentError),
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
          onPressed: () => ref.read(testCaseStateProvider.notifier).toggleTestCase(),
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

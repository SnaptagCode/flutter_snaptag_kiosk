import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_response.freezed.dart';
part 'payment_response.g.dart';

@freezed
class PaymentResponse with _$PaymentResponse {
  const factory PaymentResponse({
    required String res, // 응답코드
    String? msg, // 응답 메시지
    String? status, // 상태 - 정상승인인 경우 'O'
    String? approvalNo, // 승인번호
    String? tradeTime, // 거래시간
    String? tradeUniqueNo, // VAN TR번호
    String? originalApprovalNo, // 원거래승인번호
  }) = _PaymentResponse;

  factory PaymentResponse.fromJson(Map<String, dynamic> json) => _$PaymentResponseFromJson(json);
}

@riverpod
class PaymentResponseState extends _$PaymentResponseState {
  @override
  AsyncValue<PaymentResponse?> build() {
    return const AsyncValue.data(null);
  }

  void setResponse(PaymentResponse response) {
    state = AsyncValue.data(response);
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

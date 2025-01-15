import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_response.freezed.dart';
part 'payment_response.g.dart';

@freezed
class PaymentResponse with _$PaymentResponse {
  const factory PaymentResponse({
    @JsonKey(name: 'APPROVALNO') String? approvalNo,
    @JsonKey(name: 'CARDNAME') String? cardName,
    @JsonKey(name: 'CARDTYPE') String? cardType,
    @JsonKey(name: 'CLASSFLAG') String? classFlag,
    @JsonKey(name: 'COMPANYINFO') String? companyInfo,
    @JsonKey(name: 'CORPRESPCODE') String? corpRespCode,
    @JsonKey(name: 'RES') required String res,
    @JsonKey(name: 'MSG') String? msg,
    @JsonKey(name: 'TRADEUNIQUENO') String? tradeUniqueNo,
    @JsonKey(name: 'TRADETIME') String? tradeTime,
    @JsonKey(name: 'STATUS') String? status,
  }) = _PaymentResponse;

  factory PaymentResponse.fromJson(Map<String, dynamic> json) => _$PaymentResponseFromJson(_trimValues(json));
}

// 모든 String 값의 공백을 trim
Map<String, dynamic> _trimValues(Map<String, dynamic> json) {
  return json.map((key, value) {
    if (value is String) {
      return MapEntry(key, value.trim());
    }
    return MapEntry(key, value);
  });
}

extension PaymentResponseExtension on PaymentResponse {
  bool get isSuccess => res == '0000';
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'refund_info.freezed.dart';
part 'refund_info.g.dart';

@freezed
class RefundInfo with _$RefundInfo {
  const factory RefundInfo({
    required int kioskOrderId,
    required String originalApprovalNo,
    required String originalApprovalDate,
    required int amount,
    required int kioskEventId,
    required String photoAuthNumber,
  }) = _RefundInfo;

  factory RefundInfo.fromJson(Map<String, dynamic> json) => _$RefundInfoFromJson(json);
}

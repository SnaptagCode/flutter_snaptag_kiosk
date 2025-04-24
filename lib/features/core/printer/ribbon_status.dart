import 'package:freezed_annotation/freezed_annotation.dart';

part 'ribbon_status.freezed.dart';
part 'ribbon_status.g.dart';

@freezed
class RibbonStatus with _$RibbonStatus {
  const factory RibbonStatus({required int rbnRemaining, required int filmRemaining}) = _RibbonStatus;

  factory RibbonStatus.fromJson(Map<String, dynamic> json) => _$RibbonStatusFromJson(json);
}
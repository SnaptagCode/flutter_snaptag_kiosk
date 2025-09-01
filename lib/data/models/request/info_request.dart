import 'package:freezed_annotation/freezed_annotation.dart';

part 'info_request.freezed.dart';
part 'info_request.g.dart';

@freezed
class InfoRequest with _$InfoRequest {
  const factory InfoRequest({
    @Default('') String uniqueKey,
  }) = _InfoRequest;

  factory InfoRequest.fromJson(Map<String, dynamic> json) => _$InfoRequestFromJson(json);
}

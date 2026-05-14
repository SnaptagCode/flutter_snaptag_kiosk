import 'package:freezed_annotation/freezed_annotation.dart';

part 'unique_key_request.freezed.dart';
part 'unique_key_request.g.dart';

@freezed
class UniqueKeyRequest with _$UniqueKeyRequest {
  const factory UniqueKeyRequest({
    required String machineId,
    required String uniqueKey,
  }) = _UniqueKeyRequest;

  factory UniqueKeyRequest.fromJson(Map<String, dynamic> json) => _$UniqueKeyRequestFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_definition_response.freezed.dart';
part 'alert_definition_response.g.dart';

@freezed
class AlertDefinitionResponse with _$AlertDefinitionResponse {
  const factory AlertDefinitionResponse({
    required int id,
    required String created,
    required String modified,
    required bool isDeleted,
    required String key,
    required String category,
    required String title,
    required String description,
    String? guideText,
    String? guideUrl,
  }) = _AlertDefinitionResponse;

  factory AlertDefinitionResponse.fromJson(Map<String, dynamic> json) => _$AlertDefinitionResponseFromJson(json);
}

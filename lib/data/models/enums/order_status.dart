import 'package:json_annotation/json_annotation.dart';

enum OrderStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('FAILED')
  failed,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('REFUNDED')
  refunded,
  @JsonValue('REFUNDED_FAILED')
  refunded_failed,
}

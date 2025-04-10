import 'package:json_annotation/json_annotation.dart';

enum PrintedStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('STARTED')
  started,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('REFUNDED_AFTER_PRINTED')
  refunded_after_printed,
  @JsonValue('REFUNDED_BEFORE_PRINTED')
  refunded_before_printed,
  @JsonValue('REFUNDED_FAILED_AFTER_PRINTED')
  refunded_failed_after_printed,
  @JsonValue('REFUNDED_FAILED_BEFORE_PRINTED')
  refunded_failed_before_printed,
}

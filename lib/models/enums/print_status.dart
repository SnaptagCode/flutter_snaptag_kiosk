import 'package:json_annotation/json_annotation.dart';

enum PrintStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('STARTED')
  started,

  @JsonValue('COMPLETED')
  completed,

  @JsonValue('FAILED')
  failed,

  @JsonValue('REFUNDED_AFTER_PRINTED')
  refundedAfterPrinted,

  @JsonValue('REFUNDED_BEFORE_PRINTED')
  refundedBeforePrinted,
}

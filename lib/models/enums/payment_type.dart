import 'package:json_annotation/json_annotation.dart';

enum PaymentType {
  @JsonValue('CARD')
  card,
}

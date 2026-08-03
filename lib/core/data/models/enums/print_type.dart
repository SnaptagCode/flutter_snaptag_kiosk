import 'package:json_annotation/json_annotation.dart';

enum PrintType {
  @JsonValue('SINGLE')
  single,
  @JsonValue('DOUBLE')
  double,
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_image_config.freezed.dart';

@freezed
class LabcurityImageConfig with _$LabcurityImageConfig {
  const factory LabcurityImageConfig({
    @Default(3) int size,
    @Default(16) int strength,
    @Default(1) int alphaCode,
    @Default(0) int bravoCode,
    @Default(0) int charlieCode,
    @Default(0) int deltaCode,
    @Default(0) int echoCode,
    @Default(1) int foxtrotCode,
  }) = _LabcurityImageConfig;
}

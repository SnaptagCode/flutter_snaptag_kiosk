import 'package:freezed_annotation/freezed_annotation.dart';

part 'intro_common_data.freezed.dart';
part 'intro_common_data.g.dart';

@freezed
class IntroCommonData with _$IntroCommonData {
  const factory IntroCommonData({
    required int id,
    required String category,
    required String type,
    required String code,
    required String name,
    required String value,
    required String createdAt,
    required String updatedAt,
  }) = _IntroCommonData;

  factory IntroCommonData.fromJson(Map<String, dynamic> json) => _$IntroCommonDataFromJson(json);
}


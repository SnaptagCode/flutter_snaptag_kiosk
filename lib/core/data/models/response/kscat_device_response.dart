import 'dart:convert';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kscat_device_response.freezed.dart';
part 'kscat_device_response.g.dart';

@freezed
class KscatDeviceResponse with _$KscatDeviceResponse {
  const KscatDeviceResponse._(); // freezed에서 메서드를 추가하기 위한 private constructor

  const factory KscatDeviceResponse({
    @JsonKey(name: 'REQ') String? req,
    @JsonKey(name: 'RES') required String? res,
    @JsonKey(name: 'ERRCODE') String? errcode,
    @JsonKey(name: 'READER') String? reader,
    @JsonKey(name: 'SERIALNO') String? serialno,
    @JsonKey(name: 'SWVERSION') String? swversion,
    @JsonKey(name: 'KEYYN') String? keyyn,
    @JsonKey(name: 'BAUDRATE') String? baudrate,
    @JsonKey(name: 'KEYDATE') String? keydate,
    @JsonKey(name: 'EMVDATE') String? emvdate,
  }) = _KscatDeviceResponse;

  factory KscatDeviceResponse.fromJson(Map<String, dynamic> json) => _$KscatDeviceResponseFromJson(json);
}

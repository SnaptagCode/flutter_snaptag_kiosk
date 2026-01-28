import 'package:flutter_snaptag_kiosk/core/data/models/response/error_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_error.freezed.dart';
part 'server_error.g.dart';

@freezed
abstract class ServerError with _$ServerError {
  const factory ServerError({
    required int statusCode,
    required String timestamp,
    required String path,
    required String name,
    required ErrorResponse res,
  }) = _ServerError;

  factory ServerError.fromJson(Map<String, dynamic> json) => _$ServerErrorFromJson(json);
}

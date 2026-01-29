import 'package:freezed_annotation/freezed_annotation.dart';

part 'kscat_device_request.freezed.dart';
part 'kscat_device_request.g.dart';

@freezed
class KscatDeviceRequest with _$KscatDeviceRequest {
  const factory KscatDeviceRequest({
    required String req,
  }) = _KscatDeivceRequest;

  factory KscatDeviceRequest.fromJson(Map<String, dynamic> json) =>
      _$KscatDeviceRequestFromJson(json);
}

extension KscatDeviceRequestExtension on KscatDeviceRequest {
  String serialize() {
    final buffer = StringBuffer();

    buffer.write(req);

    final msg = buffer.toString();
    final msgLength = msg.length.toString().padLeft(4, '0');

    return 'AP$msgLength$msg';
  }
}
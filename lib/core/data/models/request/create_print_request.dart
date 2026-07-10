import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_print_request.freezed.dart';
part 'create_print_request.g.dart';

@freezed
class CreatePrintRequest with _$CreatePrintRequest {
  factory CreatePrintRequest({
    required int kioskMachineId,
    required int kioskEventId,
    required int frontPhotoCardId,
    required int backPhotoCardId,
    required int kioskOrderId,
    // 뒷면 출력 스타일 'LABELED'|'FULL'. null이면 필드 미전송 → 서버 기본 LABELED (하위호환, JKLI-214)
    @JsonKey(includeIfNull: false) String? backPhotoLayoutType,
  }) = _CreatePrintRequest;
  factory CreatePrintRequest.fromJson(Map<String, dynamic> json) => _$CreatePrintRequestFromJson(json);
}

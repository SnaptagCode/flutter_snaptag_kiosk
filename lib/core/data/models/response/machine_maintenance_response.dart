import 'package:freezed_annotation/freezed_annotation.dart';

part 'machine_maintenance_response.freezed.dart';
part 'machine_maintenance_response.g.dart';

@freezed
class MachineMaintenanceResponse with _$MachineMaintenanceResponse {
  const factory MachineMaintenanceResponse({
    required int machineId,
    required bool isUnderMaintenance,
    List<MachineLogItem>? machineLogPaths,
    List<MachineDownloadItem>? machineDownloads,
  }) = _MachineMaintenanceResponse;

  factory MachineMaintenanceResponse.fromJson(Map<String, dynamic> json) => _$MachineMaintenanceResponseFromJson(json);
}

@freezed
class MachineLogItem with _$MachineLogItem {
  const factory MachineLogItem({
    required int id,
    required String path,
    String? urlPath,
    String? deviceType,
  }) = _MachineLogItem;

  factory MachineLogItem.fromJson(Map<String, dynamic> json) => _$MachineLogItemFromJson(json);
}

@freezed
class MachineDownloadItem with _$MachineDownloadItem {
  const factory MachineDownloadItem({
    required int id,
    required String path,
    // 서버에서 base64 인코딩된 바이너리 파일 데이터
    required String content,
  }) = _MachineDownloadItem;

  factory MachineDownloadItem.fromJson(Map<String, dynamic> json) => _$MachineDownloadItemFromJson(json);
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/common/file_io/machine_file_service.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/core/data/models/request/kiosk_log_request.dart';
import 'package:flutter_snaptag_kiosk/core/data/models/response/machine_maintenance_response.dart';
import 'package:flutter_snaptag_kiosk/core/data/repositories/kiosk_repository.dart';

final machineFileHandlerProvider = Provider((ref) {
  return MachineFileHandler(ref, const MachineFileService());
});

class MachineFileHandler {
  const MachineFileHandler(this._ref, this._fileService);

  final Ref _ref;
  final MachineFileService _fileService;

  static const _maxRetries = 3;
  static const _retryDelay = Duration(milliseconds: 500);

  Future<void> _withRetry({
    required Future<void> Function() op,
    required int machineId,
    required int logId,
    required String path,
  }) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        await op();
        return;
      } catch (e) {
        if (attempt == _maxRetries) {
          SlackLogService().sendErrorLogToSlack(
            '*[MachineId: $machineId / LogId: $logId]* 파일 작업 실패 ($_maxRetries회 시도 실패) ($path): $e',
          );
        } else {
          await Future.delayed(_retryDelay);
        }
      }
    }
  }

  Future<void> sendLogFiles(List<MachineLogItem> items, int machineId) async {
    for (final item in items) {
      await _withRetry(
        op: () => _sendLogFile(item.path, item.id, machineId),
        machineId: machineId,
        logId: item.id,
        path: item.path,
      );
    }
  }

  Future<void> _sendLogFile(String path, int logId, int machineId) async {
    final now = DateTime.now();
    final dateSuffix =
        '.${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final normalizedPath = path.replaceAll('/', r'\');
    final fileName = '${normalizedPath.split(r'\').last}$dateSuffix';

    final result = await _fileService.readFile(normalizedPath);

    switch (result.status) {
      case FileReadStatus.accessError:
        throw Exception('경로 접근 실패: ${result.error}');
      case FileReadStatus.notFound:
        throw Exception('파일 없음: $normalizedPath');
      case FileReadStatus.empty:
        throw Exception('파일이 비어 있음: $normalizedPath');
      case FileReadStatus.readError:
        throw Exception('파일 읽기 실패: ${result.error}');
      case FileReadStatus.success:
        try {
          await _ref.read(kioskRepositoryProvider).sendKioskLog(
                KioskLogRequest.withLogId(
                    logId: logId, machineId: machineId, title: fileName, content: result.content!),
              );
        } catch (e) {
          SlackLogService().sendErrorLogToSlack(
            '*[MachineId: $machineId / LogId: $logId]* 로그 전송 실패 ($path): $e',
          );
        }
      case FileReadStatus.directorySuccess:
        try {
          await _ref.read(kioskRepositoryProvider).sendKioskLog(
                KioskLogRequest.withLogId(
                    logId: logId, machineId: machineId, title: '$fileName.zip', content: ''),
                zipFile: result.zipBytes,
              );
        } catch (e) {
          SlackLogService().sendErrorLogToSlack(
            '*[MachineId: $machineId / LogId: $logId]* 디렉토리 zip 전송 실패 ($path): $e',
          );
        }
    }
  }

  Future<void> downloadFiles(List<MachineDownloadItem> items, int machineId) async {
    for (final item in items) {
      final bytes = base64Decode(item.content);
      await _withRetry(
        op: () => downloadFile(item.path, bytes, item.id, machineId),
        machineId: machineId,
        logId: item.id,
        path: item.path,
      );
    }
  }

  Future<void> downloadLogFiles(List<MachineLogItem> items, int machineId) async {
    for (final item in items) {
      if (item.urlPath == null) continue;
      await _withRetry(
        op: () => downloadFileFromUrl(item.urlPath!, item.path, item.id, machineId),
        machineId: machineId,
        logId: item.id,
        path: item.path,
      );
    }
  }

  Future<void> downloadFileFromUrl(String urlPath, String path, int logId, int machineId) async {
    final normalizedPath = path.replaceAll('/', r'\');
    final fileName = normalizedPath.split(r'\').last;

    try {
      final bytes = await _fileService.downloadBytesFromUrl(urlPath);
      await _fileService.writeFile(path, bytes);

      try {
        await _ref.read(kioskRepositoryProvider).sendKioskLog(
              KioskLogRequest.withLogId(
                  logId: logId, machineId: machineId, title: fileName, content: '파일 저장 완료: $path'),
            );
      } catch (e) {
        SlackLogService().sendErrorLogToSlack(
          '*[MachineId: $machineId / LogId: $logId]* 파일 저장 완료 알림 전송 실패 ($path): $e',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadFile(String path, List<int> bytes, int logId, int machineId) async {
    final normalizedPath = path.replaceAll('/', r'\');
    final fileName = normalizedPath.split(r'\').last;

    try {
      await _fileService.writeFile(path, bytes);

      try {
        await _ref.read(kioskRepositoryProvider).sendKioskLog(
              KioskLogRequest.withLogId(
                  logId: logId, machineId: machineId, title: fileName, content: '파일 저장 완료: $path'),
            );
      } catch (e) {
        SlackLogService().sendErrorLogToSlack(
          '*[MachineId: $machineId / LogId: $logId]* 파일 저장 완료 알림 전송 실패 ($path): $e',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

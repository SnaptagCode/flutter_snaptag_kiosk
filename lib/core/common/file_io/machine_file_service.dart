import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_snaptag_kiosk/core/common/cp949/cp949_codec.dart';

enum FileReadStatus { success, directorySuccess, accessError, notFound, empty, readError }

class FileReadResult {
  const FileReadResult._({
    required this.status,
    this.content,
    this.zipBytes,
    this.error,
  });

  final FileReadStatus status;
  final String? content;
  // 디렉토리를 zip으로 묶은 raw bytes → repository에서 file 필드로 전송
  final Uint8List? zipBytes;
  final Object? error;

  // 일반 파일 읽기 성공
  factory FileReadResult.success(String content) => FileReadResult._(status: FileReadStatus.success, content: content);

  // 디렉토리 zip 성공
  factory FileReadResult.successDirectory(Uint8List zipBytes) =>
      FileReadResult._(status: FileReadStatus.directorySuccess, zipBytes: zipBytes);

  factory FileReadResult.accessError(Object error) =>
      FileReadResult._(status: FileReadStatus.accessError, error: error);

  factory FileReadResult.notFound() => FileReadResult._(status: FileReadStatus.notFound);

  factory FileReadResult.empty() => FileReadResult._(status: FileReadStatus.empty);

  factory FileReadResult.readError(Object error) => FileReadResult._(status: FileReadStatus.readError, error: error);
}

class MachineFileService {
  const MachineFileService();

  Future<FileReadResult> readFile(String normalizedPath) async {
    final file = File(normalizedPath);

    // 경로 접근 권한 오류 (exists() 자체가 throw하는 경우)
    bool exists;
    try {
      exists = await file.exists();
    } catch (e) {
      return FileReadResult.accessError(e);
    }

    if (!exists) {
      // 파일로는 없지만 디렉토리일 수 있음 → zip으로 묶어 반환
      if (await Directory(normalizedPath).exists()) {
        return _readDirectory(normalizedPath);
      }
      // 파일도 디렉토리도 아님 → 경로 자체가 없는 경우
      return FileReadResult.notFound();
    }

    // 파일 읽기
    try {
      final bytes = await file.readAsBytes();

      // 파일은 존재하지만 내용이 없는 경우
      if (bytes.isEmpty) return FileReadResult.empty();

      final ext = normalizedPath.split('.').last.toLowerCase();
      const binaryExtensions = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'pdf', 'zip', 'exe', 'dll'};

      final String content;
      if (binaryExtensions.contains(ext)) {
        // 바이너리 파일 → base64 인코딩
        content = base64Encode(bytes);
      } else {
        // UTF-8 → CP949 → latin1 순서로 디코딩 시도
        String decoded;
        try {
          decoded = utf8.decode(bytes, allowMalformed: false);
        } catch (_) {
          try {
            decoded = cp949.decode(bytes, allowInvalid: false);
          } catch (_) {
            decoded = latin1.decode(bytes);
          }
        }
        content = decoded;
      }

      return FileReadResult.success(content);
    } catch (e) {
      return FileReadResult.readError(e);
    }
  }

  // 디렉토리를 재귀 탐색하여 zip으로 묶고 raw bytes 반환
  Future<FileReadResult> _readDirectory(String dirPath) async {
    try {
      final archive = Archive();
      final dir = Directory(dirPath);

      // 하위 파일 전체를 상대경로로 archive에 추가 (폴더 구조 유지)
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          // dirPath 이후 경로만 추출 (예: logs\sub\file.txt)
          final relativePath = entity.path.substring(dirPath.length + 1);
          archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
        }
      }

      // 디렉토리가 존재하지만 파일이 하나도 없는 경우
      if (archive.isEmpty) return FileReadResult.empty();

      final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));
      return FileReadResult.successDirectory(zipBytes);
    } catch (e) {
      return FileReadResult.readError(e);
    }
  }

  Future<List<int>> downloadBytesFromUrl(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await response.fold<List<int>>([], (buf, chunk) => buf..addAll(chunk));
      return bytes;
    } finally {
      client.close();
    }
  }

  // 받아온 경로에 바이트 스트림을 파일로 저장
  // 중간 디렉토리가 없으면 자동 생성
  Future<void> writeFile(String path, List<int> bytes) async {
    final normalizedPath = path.replaceAll('/', r'\');
    final file = File(normalizedPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
  }
}

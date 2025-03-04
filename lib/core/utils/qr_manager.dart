import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_snaptag_kiosk/core/constants/directory_paths.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrManager {
  static final QrManager _instance = QrManager._internal();
  factory QrManager() => _instance;
  QrManager._internal();

  Future<void> captureAndSaveQR(String url) async {
    try {
      final qrPainter = QrPainter(
        data: url,
        version: QrVersions.auto,
      );

      // ✅ 2. QR을 PNG로 변환
      final picture = qrPainter.toPicture(200);
      final image = await picture.toImage(200, 200);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 📌 저장할 경로 설정 (앱의 Document 디렉토리)
      final path = DirectoryPaths.output.buildPath;
      final directory = Directory(path);
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/qr_code.png';

      // 📌 이미지 파일로 저장
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // print("✅ QR 코드 저장 완료: $filePath");
    } catch (e) {
      // print("❌ QR 코드 저장 실패: $e");
    }
  }
}

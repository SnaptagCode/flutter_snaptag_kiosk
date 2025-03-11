import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/core/constants/directory_paths.dart';

class FileTask {
  final int? sizeInMB;
  final String? outputPath;

  FileTask(this.sizeInMB, this.outputPath);
}

class FileIoButton extends StatelessWidget {
  const FileIoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            await runFileCreationInIsolate(100000);
          },
          child: Text('시작'),
        ),
        CircularProgressIndicator()
      ],
    );
  }

  Future<void> runFileCreationInIsolate(int sizeInMB) async {
    final outputDirPath = DirectoryPaths.output.buildPath;
    await _ensureDirectoryExists(outputDirPath);

    final receivePort = ReceivePort(); // 🎯 Isolate 통신용
    await Isolate.spawn(_createLargeFileIsolate, receivePort.sendPort);

    final sendPort = await receivePort.first as SendPort;
    final responsePort = ReceivePort();

    sendPort.send(FileTask(sizeInMB, outputDirPath));
    await responsePort.first;

    print("✅ $sizeInMB MB 파일 생성 완료: $outputDirPath");
  }

  void _createLargeFileIsolate(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    port.listen((message) async {
      if (message is FileTask) {
        final file = File('${message.outputPath}/io_test.txt');
        final sink = file.openWrite();

        // 🎯 1MB짜리 더미 데이터 생성
        final dummyData = List.generate(1024, (_) => "Flutter Large File Test Data\n").join();
        final size = message.sizeInMB ?? 0;
        for (int i = 0; i < size; i++) {
          sink.writeln(dummyData);
        }

        await sink.flush();
        await sink.close();

        print("✅ 파일 생성 완료: ${message.outputPath}");

        sendPort.send(true); // 🎯 작업 완료 신호 전송
      }
    });
  }

  Future<void> _ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }
}

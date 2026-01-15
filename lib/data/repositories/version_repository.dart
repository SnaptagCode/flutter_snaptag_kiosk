import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:package_info_plus/package_info_plus.dart';

class VersionRepository {
  final String githubRepo = "SnaptagCode/flutter_snaptag_kiosk";

  late final String home;
  late final Directory snaptagDir;
  late final Directory launcherDir;
  late final String launcherPath;

  VersionRepository() {
    home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? (throw Exception("홈 디렉토리를 가져올 수 없습니다."));

    snaptagDir = Directory(p.join(home, 'Snaptag'));
    if (!snaptagDir.existsSync()) {
      snaptagDir.createSync(recursive: true);
    }

    launcherDir = Directory(p.join(home, 'photoCode_launcher'));
    if (!launcherDir.existsSync()) {
      launcherDir.createSync(recursive: true);
    }

    launcherPath = p.join(launcherDir.path, 'launcher.exe');
  }

  Future<String> getCurrentVersion() async {
    try {
      // pubspec.yaml의 버전을 가져옵니다
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      // 버전에 'v' 접두사가 없으면 추가
      return version.startsWith('v') ? version : 'v$version';
    } catch (e) {
      // 오류 발생 시 .env.version 파일에서 읽기 시도
      return 'v0.0.0';
    }
  }

  Future<String> getLatestVersionFromGitHub() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rawVersion = data['tag_name'];
      return rawVersion;
    } else {
      throw Exception('Failed to load latest version');
    }
  }

  Future<void> writeForceUpdateTrue() async {
    final home = Platform.environment['USERPROFILE']; // Windows 전용
    if (home == null) throw Exception("홈 디렉토리를 가져올 수 없습니다.");

    final snaptagDir = Directory(p.join(home, 'Snaptag'));
    if (!snaptagDir.existsSync()) {
      snaptagDir.createSync(recursive: true);
    }

    final forceUpdatePath = p.join(snaptagDir.path, "forceUpdate.json");
    final forceUpdateFile = File(forceUpdatePath);

    final content = json.encode({"force_update": true});
    await forceUpdateFile.writeAsString(content);

    print("forceUpdate.json에 force_update: true 기록 완료");
  }
}

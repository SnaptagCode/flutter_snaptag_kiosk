import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

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
    final envFile = File('assets/.env.version');
    final version = await envFile.readAsString();
    return version ?? 'v2.4.7';
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

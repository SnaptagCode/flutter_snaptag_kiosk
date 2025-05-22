import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class ForceUpdateWriter {
  static Future<void> writeForceUpdateTrue() async {
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

class LauncherPathUtil {
  static Future<String> getLauncherPath() async {
    final home = Platform.environment['USERPROFILE'];
    if (home == null) throw Exception("홈 디렉토리를 가져올 수 없습니다.");

    final launcherDir = Directory(p.join(home, 'photoCode_launcher'));

    if (!launcherDir.existsSync()) {
      launcherDir.createSync(recursive: true);
    }

    final launcherPath = p.join(launcherDir.path, 'kiosk_app_launcher.exe');
    return launcherPath;
  }
}
import 'dart:io';

Future<String> getWindowsMacAddress() async {
  final result = await Process.run('getmac', []);
  final output = result.stdout.toString();
  //MAC 주소 추출
  final regex = RegExp(r'([0-9A-F]{2}[:-]){5}([0-9A-F]{2})', caseSensitive: false);
  final match = regex.firstMatch(output);
  print("Mac Address Match: $match");
  print("Matched Mack: ${match?.group(0)?.replaceAll('-', ':')}");
  return match?.group(0) ?? '00-00-00-00-00-00';
}

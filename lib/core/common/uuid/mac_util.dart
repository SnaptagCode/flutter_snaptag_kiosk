import 'dart:io';

Future<String> getWindowsMacAddress() async {
  final result = await Process.run('getmac', ['/v', '/fo', 'csv']);
  final lines = result.stdout.toString().split('\n').skip(1);
  final macRegex = RegExp(r'([0-9A-F]{2}[:-]){5}([0-9A-F]{2})', caseSensitive: false);

  final wiredAdapters = <({String name, String mac})>[];

  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    final cols = line.split('","');
    if (cols.length < 3) continue;

    final connectionName = cols[0].replaceAll('"', '').trim();
    final mac = macRegex.firstMatch(cols[2])?.group(0);
    if (mac == null) continue;

    final nameLower = connectionName.toLowerCase();
    if (nameLower.contains('이더넷') || nameLower.contains('ethernet')) {
      wiredAdapters.add((name: connectionName, mac: mac));
    }
  }

  // 이름 기준 정렬 → 항상 같은 유선 어댑터 선택 (이더넷 < 이더넷 2)
  wiredAdapters.sort((a, b) => a.name.compareTo(b.name));
  final selected = wiredAdapters.isNotEmpty ? wiredAdapters.first.mac : '00-00-00-00-00-00';

  return selected;
}

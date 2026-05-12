import 'dart:io';

Future<String> getWindowsMacAddress() async {
  final result = await Process.run('getmac', ['/v', '/fo', 'csv']);
  final lines = result.stdout.toString().split('\n').skip(1);
  final macRegex = RegExp(r'([0-9A-F]{2}[:-]){5}([0-9A-F]{2})', caseSensitive: false);

  String? wiredMac;

  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    final cols = line.split('","');
    if (cols.length < 3) continue;

    final connectionName = cols[0].replaceAll('"', '').trim().toLowerCase();
    final mac = macRegex.firstMatch(cols[2])?.group(0);
    if (mac == null) continue;

    if (connectionName.contains('이더넷') || connectionName.contains('ethernet')) {
      wiredMac ??= mac;
    }
  }

  final selected = wiredMac ?? '00-00-00-00-00-00';
  print('Mac Address: wired=$wiredMac, selected=$selected');
  return selected;
}

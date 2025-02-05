import 'package:flutter_soloud/flutter_soloud.dart';

Future<void> playSound() async {
  final soloud = SoLoud.instance;
  await soloud.init();
  final source = await soloud.loadAsset('assets/sounds/blop.mp3');
  await soloud.play(source);
}

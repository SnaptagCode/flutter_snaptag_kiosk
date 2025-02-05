import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/constants/image_paths.dart';
import 'package:just_audio/just_audio.dart';

final beepPlayingProvider = FutureProvider<void>((ref) async {
  final player = AudioPlayer();
  player.setAsset(SnaptagSounds.beep);
  player.play();
});

Future<void> playSound() async {
  final AudioPlayer _audioPlayer = AudioPlayer();
  _audioPlayer.setAsset(SnaptagSounds.beep);
  await _audioPlayer.play();
}

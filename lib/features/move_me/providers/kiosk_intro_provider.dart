import 'package:flutter_snaptag_kiosk/data/models/request/info_request.dart';
import 'package:flutter_snaptag_kiosk/data/models/response/info_response.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_intro_provider.g.dart';

@Riverpod(keepAlive: true)
class KioskIntro extends _$KioskIntro {
  @override
  InfoResponse? build() => null;

  Future<void> load() async {
    final uuid = await ref.read(deviceUuidProvider.future);

    final response = await ref.read(kioskRepositoryProvider).getInfo(InfoRequest(uniqueKey: uuid));

    ref.read(kioskInfoServiceProvider.notifier).updateMachineInfo(response);

    state = response;
  }
}

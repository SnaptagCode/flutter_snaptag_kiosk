import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/common/log/app_log_service.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_info_service.g.dart';

final getInfoByKeyProvider = StateProvider<bool>((ref) => true);

@Riverpod(keepAlive: true)
class KioskInfoService extends _$KioskInfoService {
  bool _getInfoByKey = true;

  bool get getInfoByKey => _getInfoByKey;

  @override
  KioskMachineInfo? build() {
    return null;
  }

  Future<void> refreshWithMachineId(int machineId) async {
    state = null;
    await getKioskMachineInfo();
  }

  Future<KioskMachineInfo?> getKioskMachineInfo() async {
    if (state != null) return state;

    try {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      final file = File(p.join(exeDir, 'config.json'));
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      state = KioskMachineInfo.fromJson(json);
      AppLogService.instance.info('config.json 로드 완료 (eventId: ${state?.kioskEventId})');
    } catch (_) {
      state = KioskMachineInfo();
      AppLogService.instance.info('config.json 없음 - 기본값 사용');
    }

    ref.read(frontPhotoListProvider.notifier).loadLocal();
    final count = state?.singleCardCount ?? 0;
    if (count > 0) {
      await ref.read(cardCountProvider.notifier).update(count);
      AppLogService.instance.info('단면 카드 수량 로드: $count');
    }
    _getInfoByKey = true;
    ref.read(getInfoByKeyProvider.notifier).state = true;
    return state;
  }
}

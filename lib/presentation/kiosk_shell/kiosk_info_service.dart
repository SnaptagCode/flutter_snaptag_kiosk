import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/local/local_db_service.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/local/offline_config_service.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_info_service.g.dart';

final getInfoByKeyProvider = StateProvider<bool>((ref) => true);

@Riverpod(keepAlive: true)
class KioskInfoService extends _$KioskInfoService {
  @override
  KioskMachineInfo? build() => null;

  Future<KioskMachineInfo?> getKioskMachineInfo() async {
    if (state != null) return state;

    try {
      final config = await ref.read(offlineConfigServiceProvider).load();
      state = config;
      ref.read(frontPhotoListProvider.notifier).fetch();
      ref.read(getInfoByKeyProvider.notifier).state = true;
      await _restoreCardCount();
      return config;
    } catch (e) {
      ref.read(getInfoByKeyProvider.notifier).state = false;
      return null;
    }
  }

  Future<void> _restoreCardCount() async {
    final localDb = ref.read(localDbServiceProvider);
    final mode = ref.read(pagePrintProvider);
    final isSingle = mode != PagePrintType.double;
    final initial = await localDb.getInitialCount(isSingle: isSingle);
    final remaining = await localDb.getRemainingCount(isSingle: isSingle);
    ref.read(cardCountProvider.notifier).update(initial);
    ref.read(cardCountProvider.notifier).updateCurrent(remaining);
  }

  Future<KioskMachineInfo?> refreshWithMachineId(int machineId) async {
    try {
      final config = await ref.read(offlineConfigServiceProvider).load();
      state = config;
      ref.read(frontPhotoListProvider.notifier).fetch();
      ref.read(getInfoByKeyProvider.notifier).state = true;
      return config;
    } catch (e) {
      ref.read(getInfoByKeyProvider.notifier).state = false;
      return null;
    }
  }
}

import 'package:flutter_snaptag_kiosk/domain/usecases/setup/refresh_event_preview_use_case.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/di/setup_di.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/notifier/event_preview_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/notifier/event_preview_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/uuid_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_preview_notifier.g.dart';

@riverpod
class EventPreviewNotifier extends _$EventPreviewNotifier {
  late final RefreshEventPreviewUseCase _refreshUseCase;

  @override
  EventPreviewState build() {
    _refreshUseCase = ref.watch(refreshEventPreviewUseCaseProvider);
    return const EventPreviewState.initial();
  }

  Future<void> onAction(EventPreviewAction action) async {
    switch (action) {
      case EventPreviewActionRequestRefresh():
        break;

      case EventPreviewActionConfirmRefresh(:final machineId):
        await _executeRefresh(machineId);
    }
  }

  Future<void> _executeRefresh(int machineId) async {
    state = const EventPreviewState.loading();
    try {
      final deviceUUID = await ref.read(deviceUuidProvider.future);
      await ref.read(kioskInfoServiceProvider.notifier).refreshWithMachineId(machineId);
      await _refreshUseCase.call(machineId: machineId, deviceUUID: deviceUUID);
      state = const EventPreviewState.refreshSuccess();
    } catch (e) {
      state = EventPreviewState.failure(e);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/notifier/event_preview_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/notifier/event_preview_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/notifier/event_preview_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/screen/event_preview_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/screen/event_preview_screen_state.dart';
import 'package:loader_overlay/loader_overlay.dart';

class EventPreviewRoot extends ConsumerStatefulWidget {
  const EventPreviewRoot({super.key});

  @override
  ConsumerState<EventPreviewRoot> createState() => _EventPreviewRootState();
}

class _EventPreviewRootState extends ConsumerState<EventPreviewRoot> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(eventPreviewNotifierProvider.notifier);
    final info = ref.watch(kioskInfoServiceProvider);

    final screenState = EventPreviewScreenState(info: info);

    ref.listen<EventPreviewState>(eventPreviewNotifierProvider, (_, state) async {
      switch (state) {
        case EventPreviewStateLoading():
          if (!context.loaderOverlay.visible) context.loaderOverlay.show();

        case EventPreviewStateInitial():
        case EventPreviewStateRefreshSuccess():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();

        case EventPreviewStateFailure():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (!context.mounted) return;
          await DialogHelper.showSetupDialog(context, title: '새로고침에 실패했습니다.');
          if (!context.mounted) return;
          notifier.onAction(const EventPreviewAction.requestRefresh());
      }
    });

    return LoaderOverlay(
      overlayWidgetBuilder: (_) => Center(
        child: SizedBox(
          width: 350.h,
          height: 350.h,
          child: CircularProgressIndicator(strokeWidth: 15.h),
        ),
      ),
      child: EventPreviewScreen(
        state: screenState,
        onAction: (action) async {
          switch (action) {
            case EventPreviewActionRequestRefresh():
              // 키패드 → 확인 다이얼로그 → 실제 refresh
              final value = await DialogHelper.showKeypadDialog(context, mode: ModeType.event);
              if (value == null || value.isEmpty) return;
              if (!context.mounted) return;

              final confirmed = await DialogHelper.showSetupDialog(
                context,
                title: '최신 이벤트로 새로고침 됩니다.',
                showCancelButton: true,
              );
              if (!context.mounted) return;
              if (confirmed) {
                notifier.onAction(EventPreviewAction.confirmRefresh(int.parse(value)));
              }

            case EventPreviewActionConfirmRefresh():
              notifier.onAction(action);
          }
        },
        onBack: () async {
          final result = await DialogHelper.showSetupDialog(
            context,
            title: '메인페이지로 이동합니다.',
            showCancelButton: true,
          );
          if (result && context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

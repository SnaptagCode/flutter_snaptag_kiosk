import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/kiosk_info_widget.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/notifier/event_preview_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/event_preview/screen/event_preview_screen_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventPreviewScreen extends StatelessWidget {
  final EventPreviewScreenState state;
  final void Function(EventPreviewAction) onAction;
  final VoidCallback onBack;

  const EventPreviewScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final info = state.info;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.only(left: 30.w),
          icon: SvgPicture.asset(SnaptagSvg.arrowBack),
          onPressed: onBack,
        ),
        title: const Text('이벤트 미리보기'),
        backgroundColor: Colors.white.withOpacity(0.7),
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => onAction(const EventPreviewAction.requestRefresh()),
            icon: SvgPicture.asset('assets/icons/refresh.svg'),
          ),
        ],
      ),
      body: info == null
          ? const Center(
              child: Text(
                '진행중인\n이벤트가 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Image.network(
                  info.topBannerUrl,
                  errorBuilder: (_, __, ___) => Flexible(
                    child: Center(child: const CircularProgressIndicator()),
                  ),
                ),
                if (info.topBannerUrl.isNotEmpty)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        info.mainImageUrl,
                        errorBuilder: (_, __, ___) => Flexible(
                          flex: 3,
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                      if (F.appFlavor == Flavor.dev) KioskInfoWidget(info: info),
                    ],
                  ),
              ],
            ),
    );
  }
}

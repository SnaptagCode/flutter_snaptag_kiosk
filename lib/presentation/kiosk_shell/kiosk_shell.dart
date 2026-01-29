import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/back_button.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/kiosk_navigator_button.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/printer_status_badge.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/triple_tap_fab.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:loader_overlay/loader_overlay.dart';

class KioskShell extends ConsumerStatefulWidget {
  final Widget child;

  const KioskShell({super.key, required this.child});

  @override
  ConsumerState<KioskShell> createState() => _KioskShellState();
}

class _KioskShellState extends ConsumerState<KioskShell> {
  Timer? _periodicTimer;
  bool _hasNetworkError = false;

  @override
  void initState() {
    super.initState();

    _periodicTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      SlackLogService().sendPeriodicLogBroadcastLogToSlack();
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(kioskInfoServiceProvider);

    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 855.h,
                width: double.infinity,
                child: Image.network(
                  settings?.topBannerUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('이미지를 찾을 수 없습니다.'));
                  },
                ),
              ),
              Expanded(
                child: LoaderOverlay(
                  overlayWidgetBuilder: (_) => Center(
                    child: SizedBox(
                      width: 350.h,
                      height: 350.h,
                      child: CircularProgressIndicator(strokeWidth: 15.h),
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: !_hasNetworkError
                          ? DecorationImage(
                              image: NetworkImage(settings?.mainImageUrl ?? ''),
                              onError: (_, __) {
                                if (mounted) {
                                  setState(() {
                                    _hasNetworkError = true;
                                  });
                                }
                              },
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/fallback_body.jpg'),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 70.h,
                          child: Row(
                            children: [
                              SizedBox(width: 30.w),
                              KioskBackButton(),
                              const Spacer(),
                              KioskNavigatorButton(),
                              SizedBox(width: 30.w),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widget.child,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: TripleTapFloatingButton(),
        ),
        const Positioned(
          top: 20,
          left: 20,
          child: FloatingPrinterStatusBadge(),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/back_button.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/kiosk_navigator_button.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/printer_status_badge.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/triple_tap_fab.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart' as p;

class KioskShell extends ConsumerWidget {
  final Widget child;

  const KioskShell({super.key, required this.child});

  static String get _exeDir => p.dirname(Platform.resolvedExecutable);

  static File get _bannerFile => _findImageFile('banner');
  static File get _backgroundFile => _findImageFile('background');

  static File _findImageFile(String name) {
    for (final ext in ['jpg', 'jpeg', 'png']) {
      final f = File(p.join(_exeDir, 'image', '$name.$ext'));
      if (f.existsSync()) return f;
    }
    return File(p.join(_exeDir, 'image', '$name.jpg'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(kioskInfoServiceProvider);

    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 855.h,
                width: double.infinity,
                child: _bannerFile.existsSync()
                    ? Image.file(_bannerFile, fit: BoxFit.cover)
                    : const AssetImage('assets/images/fallback_body.jpg') as Widget,
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
                      image: DecorationImage(
                        image: _backgroundFile.existsSync()
                            ? FileImage(_backgroundFile) as ImageProvider
                            : const AssetImage('assets/images/fallback_body.jpg'),
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
                            children: [child],
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

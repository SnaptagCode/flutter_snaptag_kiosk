import 'dart:async';
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

class KioskShell extends ConsumerStatefulWidget {
  final Widget child;

  const KioskShell({super.key, required this.child});

  @override
  ConsumerState<KioskShell> createState() => _KioskShellState();
}

class _KioskShellState extends ConsumerState<KioskShell> {
  Timer? _periodicTimer;

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.read(kioskInfoServiceProvider);

    final exeDir = p.dirname(Platform.resolvedExecutable);
    final imageDir = Directory(p.join(exeDir, 'image'));
    const exts = ['.jpg', '.jpeg', '.png', '.webp'];

    File? findImage(String baseName) {
      if (!imageDir.existsSync()) return null;
      for (final ext in exts) {
        final f = File(p.join(imageDir.path, '$baseName$ext'));
        if (f.existsSync()) return f;
      }
      return null;
    }

    final bannerFile = findImage('banner');
    final bgFile = findImage('background');

    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 855.h,
                width: double.infinity,
                child: bannerFile != null
                    ? Image.file(bannerFile, fit: BoxFit.cover)
                    : Image.asset('assets/images/fallback_body.jpg', fit: BoxFit.cover),
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
                        image: bgFile != null
                            ? FileImage(bgFile) as ImageProvider
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

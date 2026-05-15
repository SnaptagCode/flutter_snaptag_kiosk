import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:flutter_snaptag_kiosk/locale_keys.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';

class PrintProcessScreen extends ConsumerWidget {
  final AnimationController progressController;
  final bool progressCompleted;
  final String? adImagePath;

  const PrintProcessScreen({
    super.key,
    required this.progressController,
    required this.progressCompleted,
    required this.adImagePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHwe = ref.watch(kioskInfoServiceProvider)?.isHwe == true;
    final mainTextColor =
        ref.watch(kioskInfoServiceProvider)?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.sub03_txt_01.tr(),
              textAlign: TextAlign.center,
              style: isHwe
                  ? context.typography.vendingTitle2B.copyWith(color: mainTextColor)
                  : context.typography.kioskBody1B.copyWith(fontSize: 40.sp, color: mainTextColor),
            ),
            SizedBox(height: 23.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Text(
                LocaleKeys.sub03_txt_02.tr(),
                textAlign: TextAlign.center,
                style: isHwe
                    ? context.typography.vendingBody1B
                        .copyWith(color: mainTextColor, fontSize: 36.sp, letterSpacing: -0.8)
                    : context.typography.kioskBody1B.copyWith(fontSize: 30.sp, color: mainTextColor),
              ),
            ),
            SizedBox(height: 60.h),
            adImagePath == null
                ? Container(
                    width: 1080.w,
                    height: 400.h,
                    decoration: BoxDecoration(border: Border.all(color: Colors.transparent, width: 0.w)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.asset(SnaptagImages.printLoading),
                    ),
                  )
                : SizedBox(
                    width: 1080.w,
                    height: 400.h,
                    child: Image.file(
                      File(adImagePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
            SizedBox(height: 40.h),
            AnimatedBuilder(
              animation: progressController,
              builder: (context, child) {
                final raw = progressController.value;
                final percent = progressCompleted ? 100 : (raw * 100).floor().clamp(0, 99);
                return _PrintProgressBar(
                  progress: progressCompleted ? 1.0 : raw,
                  label: '$percent%',
                );
              },
            ),
            SizedBox(height: 16.h),
            Text(
              LocaleKeys.sub03_txt_03.tr(),
              textAlign: TextAlign.center,
              style: isHwe
                  ? context.typography.vendingBody2B.copyWith(color: mainTextColor, letterSpacing: 1.2)
                  : context.typography.kioskBody2B.copyWith(color: mainTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrintProgressBar extends StatelessWidget {
  const _PrintProgressBar({
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final kioskColors = context.theme.extension<KioskColors>()!;

    return SizedBox(
      width: 540.w,
      height: 35.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0x4DFFFFFF),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.r),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: clamped,
                  heightFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            kioskColors.progressBarStartColor,
                            kioskColors.progressBarEndColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    label,
                    style: context.typography.kioskBody1B.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static File? _getEmblemFile() {
    final path = p.join(p.dirname(Platform.resolvedExecutable), 'assets', 'emblem', 'HanwhaEmblem.png');
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final isHwe = kiosk?.isHwe ?? false;
    final buttonColor = kiosk?.mainButtonColor.toColor() ?? Colors.black;
    final buttonTextColor = kiosk?.buttonTextColor.toColor(fallback: Colors.white) ?? Colors.white;
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    final imageFile = _getEmblemFile();

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.choice_select_back_image.tr(),
            style: isHwe
                ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          GestureDetector(
            onTap: () {
              ref.read(backPhotoTypeProvider.notifier).selectFixed(0);
              PhotoCardPreviewRouteData().go(context);
            },
            child: Container(
              width: 423.w,
              height: 649.h,
              margin: EdgeInsets.symmetric(vertical: 22.h),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23.r),
                  side: BorderSide(color: Colors.white, width: 1.w),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GradientOverlayPainter(
                        topAlpha: 0.20,
                        bottomAlpha: 0.30,
                        dividerHeight: 177.h,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 177.h,
                        child: Column(
                          children: [
                            SizedBox(height: 27.h),
                            Text(
                              LocaleKeys.choice_recommended_images.tr(),
                              style: isHwe
                                  ? context.typography.vendingTitle2B.copyWith(color: buttonColor)
                                  : context.typography.kioskBtn1B.copyWith(
                                      fontSize: context.locale.languageCode == 'en' ? 32.sp : 45.sp,
                                      color: buttonColor,
                                    ),
                              textAlign: TextAlign.center,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  LocaleKeys.choice_select_and_print.tr(),
                                  style: isHwe
                                      ? context.typography.vendingBody4B
                                          .copyWith(color: mainTextColor, fontSize: 25.sp)
                                      : context.typography.kioskBtn1B
                                          .copyWith(fontSize: 25.sp, color: mainTextColor),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 40.h),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: imageFile != null
                                  ? Image.file(imageFile, width: 264.w, height: 264.h, fit: BoxFit.contain)
                                  : Container(
                                      width: 264.w,
                                      height: 264.h,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
                                    ),
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Container(
                            width: 282.w,
                            height: 67.h,
                            decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              LocaleKeys.home_btn_start.tr(),
                              style: isHwe
                                  ? context.typography.vendingBtn3B.copyWith(color: buttonTextColor, fontSize: 32.sp)
                                  : context.typography.kioskBtn1B.copyWith(
                                      fontSize: context.locale.languageCode == 'en' ? 25.sp : 30.sp,
                                      color: buttonTextColor,
                                    ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}

class _GradientOverlayPainter extends CustomPainter {
  final double topAlpha;
  final double bottomAlpha;
  final double dividerHeight;

  _GradientOverlayPainter({
    required this.topAlpha,
    required this.bottomAlpha,
    required this.dividerHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, dividerHeight),
      Paint()..color = Colors.white.withValues(alpha: topAlpha),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, dividerHeight, size.width, size.height - dividerHeight),
      Paint()..color = Colors.white.withValues(alpha: bottomAlpha),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

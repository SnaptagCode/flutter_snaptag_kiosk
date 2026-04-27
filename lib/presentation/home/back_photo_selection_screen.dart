import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:path/path.dart' as p;

class BackPhotoSelectionScreen extends ConsumerWidget {
  const BackPhotoSelectionScreen({super.key});

  static Directory get _backPhotosDir =>
      Directory(p.join(p.dirname(Platform.resolvedExecutable), 'image', 'back_photos'));

  List<File> _getBackPhotoFiles() {
    if (!_backPhotosDir.existsSync()) return [];
    return _backPhotosDir
        .listSync()
        .whereType<File>()
        .where((f) {
          final lower = f.path.toLowerCase();
          return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp');
        })
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final isHwe = kiosk?.isHwe ?? false;
    final buttonColor = kiosk?.mainButtonColor.toColor() ?? Colors.black;
    final buttonTextColor = kiosk?.buttonTextColor.toColor(fallback: Colors.white) ?? Colors.white;
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    final files = _getBackPhotoFiles();

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.choice_recommended_images.tr(),
            style: isHwe
                ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          ..._buildPhotoRows(context, ref,
              files: files,
              isHwe: isHwe,
              buttonColor: buttonColor,
              buttonTextColor: buttonTextColor,
              mainTextColor: mainTextColor),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }

  List<Widget> _buildPhotoRows(
    BuildContext context,
    WidgetRef ref, {
    required List<File> files,
    required bool isHwe,
    required Color buttonColor,
    required Color buttonTextColor,
    required Color mainTextColor,
  }) {
    if (files.isEmpty) return [const SizedBox.shrink()];

    final rows = <Widget>[];
    for (int i = 0; i < files.length; i += 2) {
      if (i > 0) rows.add(SizedBox(height: 20.h));
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPhotoCard(context, ref,
              file: files[i],
              index: i,
              isHwe: isHwe,
              buttonColor: buttonColor,
              buttonTextColor: buttonTextColor,
              mainTextColor: mainTextColor),
          if (i + 1 < files.length) ...[
            SizedBox(width: 40.w),
            _buildPhotoCard(context, ref,
                file: files[i + 1],
                index: i + 1,
                isHwe: isHwe,
                buttonColor: buttonColor,
                buttonTextColor: buttonTextColor,
                mainTextColor: mainTextColor),
          ],
        ],
      ));
    }
    return rows;
  }

  Widget _buildPhotoCard(
    BuildContext context,
    WidgetRef ref, {
    required File file,
    required int index,
    required bool isHwe,
    required Color buttonColor,
    required Color buttonTextColor,
    required Color mainTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(backPhotoTypeProvider.notifier).selectFixed(index);
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
                        child: Image.file(file, width: 264.w, height: 264.h, fit: BoxFit.contain),
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
                        LocaleKeys.choice_btn_print.tr(),
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

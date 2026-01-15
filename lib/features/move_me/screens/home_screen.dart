import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final buttonColor = kiosk?.mainButtonColor != null
        ? Color(int.parse(kiosk!.mainButtonColor.replaceFirst('#', '0xff')))
        : Colors.black;
    final buttonTextColor = kiosk?.buttonTextColor != null
        ? Color(int.parse(kiosk!.buttonTextColor.replaceFirst('#', '0xff')))
        : Colors.white;
    final mainTextColor =
        kiosk?.mainTextColor != null ? Color(int.parse(kiosk!.mainTextColor.replaceFirst('#', '0xff'))) : Colors.white;
    String priceValue = NumberFormat.currency(locale: 'ko_KR', symbol: '').format(kiosk?.photoCardPrice);

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 34.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Text(
              '1EA | $priceValue${LocaleKeys.currency_won.tr()}',
              style: TextStyle(
                fontSize: 30.sp,
                color: buttonTextColor,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            LocaleKeys.choice_select_back_image.tr(),
            style: context.typography.kioskBtn1B.copyWith(fontSize: 52.sp, color: mainTextColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRecommendedImageCard(
                context,
                title: LocaleKeys.choice_recommended_images.tr(),
                subtitle1: LocaleKeys.choice_select_and_print.tr(),
                subtitle2: null,
                subtitleSize: 25.sp,
                imageUrl: kiosk?.emblemImageUrl ?? '',
                mainButtonColor: buttonColor,
                buttonTextColor: buttonTextColor,
                mainTextColor: mainTextColor,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(kiosk?.emblemImageUrl ?? '', width: 264.w, height: 264.h, fit: BoxFit.cover),
                ),
                onTap: () async {
                  ref.read(backPhotoTypeProvider.notifier).selectFixed(0);
                  PhotoCardPreviewRouteData().go(context);
                },
              ),
              SizedBox(width: 40.w),
              _buildRecommendedImageCard(
                context,
                title: LocaleKeys.choice_upload_my_photo.tr(),
                subtitle1: LocaleKeys.choice_step1_qr_upload.tr(),
                subtitle2: LocaleKeys.choice_step2_enter_code_print.tr(),
                subtitleSize: 20.sp,
                imageUrl: null,
                mainButtonColor: buttonColor,
                buttonTextColor: buttonTextColor,
                mainTextColor: mainTextColor,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: QrImageView(
                    data:
                        '${F.qrCodePrefix}/${context.locale.languageCode}/${ref.read(kioskInfoServiceProvider)?.kioskEventId} ',
                    size: 264.r,
                    version: QrVersions.auto,
                    padding: EdgeInsets.all(20.r),
                  ),
                ),
                onTap: () async {
                  ref.read(backPhotoTypeProvider.notifier).selectCustom();
                  CodeVerificationRouteData().go(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 추천 이미지 카드 위젯 빌드
  Widget _buildRecommendedImageCard(
    BuildContext context, {
    required String title,
    required String subtitle1,
    required String? subtitle2,
    required double subtitleSize,
    required String? imageUrl,
    required Color mainButtonColor,
    required Color buttonTextColor,
    required Color mainTextColor,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 423.w,
        height: 649.h,
        margin: EdgeInsets.symmetric(vertical: 22.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23.r),
            side: BorderSide(
              color: Colors.white,
              width: 1.w,
            ),
          ),
        ),
        child: Stack(
          children: [
            // 그라데이션 오버레이
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
                        title,
                        style: context.typography.kioskBtn1B.copyWith(
                          fontSize: context.locale.languageCode == 'en' ? 32.sp : 45.sp,
                          color: mainButtonColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: subtitle2 == null ? MainAxisAlignment.center : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subtitle1,
                                style: context.typography.kioskBtn1B
                                    .copyWith(fontSize: subtitleSize, color: mainTextColor),
                                textAlign: TextAlign.left,
                              ),
                              if (subtitle2 != null) SizedBox(height: 10.h),
                              if (subtitle2 != null)
                                Text(
                                  subtitle2,
                                  style: context.typography.kioskBtn1B
                                      .copyWith(fontSize: subtitleSize, color: mainTextColor),
                                  textAlign: TextAlign.left,
                                ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 40.h),
                    Center(
                      child: child,
                    ),
                    SizedBox(height: 40.h),
                    Container(
                      width: 282.w,
                      height: 67.h,
                      padding: EdgeInsets.symmetric(horizontal: 23.5.w, vertical: 18.5.h),
                      decoration: BoxDecoration(
                        color: mainButtonColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        imageUrl != null ? LocaleKeys.choice_select_image.tr() : LocaleKeys.choice_enter_code.tr(),
                        style: context.typography.kioskBtn1B.copyWith(
                            fontSize: context.locale.languageCode == 'en' ? 25.sp : 30.sp, color: buttonTextColor),
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

  Widget _buildChoiceButton(BuildContext context, WidgetRef ref, String url,
      {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 307.w,
        height: 485.h,
        margin: EdgeInsets.symmetric(vertical: 22.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        alignment: Alignment.center,
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
                ),
              ),
      ),
    );
  }
}

/// 그라데이션 오버레이를 그리는 CustomPainter
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
    // 상단 영역 (height 177까지, alpha 55%)
    final topRect = Rect.fromLTWH(0, 0, size.width, dividerHeight);
    final topPaint = Paint()
      ..color = Colors.white.withOpacity(topAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawRect(topRect, topPaint);

    // 하단 영역 (나머지, alpha 32%)
    final bottomRect = Rect.fromLTWH(0, dividerHeight, size.width, size.height - dividerHeight);
    final bottomPaint = Paint()
      ..color = Colors.white.withOpacity(bottomAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawRect(bottomRect, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

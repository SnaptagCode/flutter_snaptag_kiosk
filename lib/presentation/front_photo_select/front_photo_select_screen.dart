import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/photo_card_carousel.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/front_photo_select/selected_front_photo_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';

/// 앞면 이미지 선택 화면 (선택형 이벤트 전용)
class FrontPhotoSelectScreen extends ConsumerWidget {
  const FrontPhotoSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final photos = ref.watch(frontPhotoListProvider);
    final selectedPhoto = ref.watch(selectedFrontPhotoProvider);
    final isHwe = kiosk?.isHwe ?? false;
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;
    final buttonColor = kiosk?.mainButtonColor.toColor() ?? Colors.black;
    final buttonTextColor = (kiosk?.buttonTextColor ?? '').toColor(fallback: Colors.white);

    final foundIndex = selectedPhoto == null ? -1 : photos.indexWhere((photo) => photo.id == selectedPhoto.id);
    final selectedIndex = foundIndex < 0 ? null : foundIndex;

    // KioskShell이 화면을 높이 무제한 Column(center) 안에 배치하므로 Expanded 대신 고정 높이를 사용해야 한다.
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.front_photo_select_title.tr(),
            textAlign: TextAlign.center,
            style: isHwe
                ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
          ),
          SizedBox(height: 12.h),
          Text(
            LocaleKeys.front_photo_select_subtitle.tr(),
            textAlign: TextAlign.center,
            style: isHwe
                ? context.typography.vendingBody4B.copyWith(color: mainTextColor.withValues(alpha: 0.85))
                : context.typography.kioskBody1B
                    .copyWith(fontSize: 26.sp, color: mainTextColor.withValues(alpha: 0.85)),
          ),
          SizedBox(height: 36.h),
          if (photos.isEmpty)
            SizedBox(
              height: 500.h,
              child: Center(
                child: Text(
                  LocaleKeys.front_photo_select_empty.tr(),
                  textAlign: TextAlign.center,
                  style: isHwe
                      ? context.typography.vendingBody2B.copyWith(color: mainTextColor)
                      : context.typography.kioskBody2B.copyWith(color: mainTextColor),
                ),
              ),
            )
          else
            PhotoCardCarousel(
              key: ValueKey(photos.length),
              items: [
                for (final photo in photos)
                  PhotoCardCarouselItem(imageFile: photo.embedImage, imageUrl: photo.originUrl),
              ],
              selectedIndex: selectedIndex,
              onSelect: (index) => ref.read(selectedFrontPhotoProvider.notifier).select(photos[index]),
              arrowBgColor: buttonColor,
              arrowFgColor: buttonTextColor,
              indicatorActiveColor: buttonColor,
              indicatorInactiveColor: mainTextColor.withValues(alpha: 0.35),
              viewportHeight: 500.h,
              cardWidth: 300.w,
              cardHeight: 471.h,
            ),
          SizedBox(height: 30.h),
          SizedBox(
            width: 520.w,
            height: 82.h,
            child: ElevatedButton(
              style: context.mainLargeButtonStyle,
              onPressed: selectedPhoto == null
                  ? null
                  : () async {
                      await SoundManager().playSound();
                      if (context.mounted) PhotoCardPreviewRouteData().go(context);
                    },
              child: Text(
                LocaleKeys.choice_select_image.tr(),
                style: isHwe
                    ? context.typography.vendingBtn2B.copyWith(color: buttonTextColor)
                    : context.typography.kioskBtn1B.copyWith(color: buttonTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

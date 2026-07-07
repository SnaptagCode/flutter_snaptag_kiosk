import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/photo_card_carousel.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';

/// 뒷면 이미지 선택 화면 (고정 뒷면이 여러 장일 때)
///
/// 앞면 선택 화면과 동일한 슬라이더로 nominatedBackPhotoCardList에서 하나를 고른다.
/// 선택은 [backPhotoTypeProvider]의 fixedIndex로 유지된다.
class BackPhotoSelectScreen extends ConsumerWidget {
  const BackPhotoSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final backCards = kiosk?.nominatedBackPhotoCardList ?? [];
    final selection = ref.watch(backPhotoTypeProvider);
    final selectedIndex = selection?.fixedIndex;
    final isHwe = kiosk?.isHwe ?? false;
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;
    final buttonColor = kiosk?.mainButtonColor.toColor() ?? Colors.black;
    final buttonTextColor = (kiosk?.buttonTextColor ?? '').toColor(fallback: Colors.white);

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.back_photo_select_title.tr(),
            textAlign: TextAlign.center,
            style: isHwe
                ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
          ),
          SizedBox(height: 12.h),
          Text(
            LocaleKeys.back_photo_select_subtitle.tr(),
            textAlign: TextAlign.center,
            style: isHwe
                ? context.typography.vendingBody4B.copyWith(color: mainTextColor.withValues(alpha: 0.85))
                : context.typography.kioskBody1B
                    .copyWith(fontSize: 26.sp, color: mainTextColor.withValues(alpha: 0.85)),
          ),
          SizedBox(height: 36.h),
          PhotoCardCarousel(
            key: ValueKey(backCards.length),
            items: [for (final card in backCards) PhotoCardCarouselItem(imageUrl: card.originUrl)],
            selectedIndex: selectedIndex,
            onSelect: (index) => ref.read(backPhotoTypeProvider.notifier).selectFixed(index),
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
              onPressed: selectedIndex == null
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

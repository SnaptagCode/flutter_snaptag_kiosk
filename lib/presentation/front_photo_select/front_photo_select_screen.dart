import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/selectable_photo_card.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/front_photo_select/selected_front_photo_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';

/// 앞면 이미지 선택 화면 (선택형 이벤트 전용)
///
/// 뒷면 고정 이미지 선택(PaymentScreen)과 동일한 디자인(SelectablePhotoCard)으로,
/// 가로 슬라이더에서 앞면 후보를 넘겨보고 탭으로 선택한 뒤
/// 하단 '이미지 선택하기' 버튼으로 결제(미리보기) 화면에 진입한다.
class FrontPhotoSelectScreen extends ConsumerStatefulWidget {
  const FrontPhotoSelectScreen({super.key});

  @override
  ConsumerState<FrontPhotoSelectScreen> createState() => _FrontPhotoSelectScreenState();
}

class _FrontPhotoSelectScreenState extends ConsumerState<FrontPhotoSelectScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 이전에 선택한 앞면이 있으면 해당 카드에서 시작
    final photos = ref.read(frontPhotoListProvider);
    final selected = ref.read(selectedFrontPhotoProvider);
    final initialIndex = selected == null ? -1 : photos.indexWhere((photo) => photo.id == selected.id);
    _currentPage = initialIndex < 0 ? 0 : initialIndex;
    _pageController = PageController(viewportFraction: 0.36, initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final photos = ref.watch(frontPhotoListProvider);
    final selectedPhoto = ref.watch(selectedFrontPhotoProvider);
    final isHwe = kiosk?.isHwe ?? false;
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;
    final buttonColor = kiosk?.mainButtonColor.toColor() ?? Colors.black;
    final buttonTextColor = (kiosk?.buttonTextColor ?? '').toColor(fallback: Colors.white);

    // 선택된 앞면의 인덱스 (리스트 갱신으로 사라졌으면 미선택 취급)
    final foundIndex = selectedPhoto == null ? -1 : photos.indexWhere((photo) => photo.id == selectedPhoto.id);
    final selectedIndex = foundIndex < 0 ? null : foundIndex;

    // KioskShell이 화면을 높이 무제한 Column(center) 안에 배치하므로
    // Expanded 대신 고정 높이를 사용해야 한다 (가용 영역 약 995.h).
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
          SizedBox(
            height: 585.h,
            child: photos.isEmpty
                ? Center(
                    child: Text(
                      LocaleKeys.front_photo_select_empty.tr(),
                      textAlign: TextAlign.center,
                      style: isHwe
                          ? context.typography.vendingBody2B.copyWith(color: mainTextColor)
                          : context.typography.kioskBody2B.copyWith(color: mainTextColor),
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          // 중앙에서 멀어질수록 카드 축소 (캐러셀 효과)
                          final page = _pageController.hasClients && _pageController.position.haveDimensions
                              ? _pageController.page ?? _currentPage.toDouble()
                              : _currentPage.toDouble();
                          final distance = (page - index).abs().clamp(0.0, 1.0);
                          final scale = 1.0 - distance * 0.12;
                          return Center(
                            child: Transform.scale(scale: scale, child: child),
                          );
                        },
                        child: SelectablePhotoCard(
                          width: 356.w,
                          height: 560.h,
                          index: index,
                          selectedIndex: selectedIndex,
                          imageFile: photo.embedImage,
                          imageUrl: photo.originUrl,
                          fit: BoxFit.cover,
                          showCheckBadge: true,
                          onTap: () {
                            // 옆 카드를 탭하면 가운데로 이동하며 선택
                            if (index != _currentPage) {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              );
                            }
                            ref.read(selectedFrontPhotoProvider.notifier).select(photo);
                          },
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 20.h),
          if (photos.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: isActive ? 28.w : 12.w,
                  height: 12.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: isActive ? buttonColor : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                );
              }),
            ),
          SizedBox(height: 30.h),
          ElevatedButton(
            style: context.paymentButtonStyle,
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
        ],
      ),
    );
  }
}

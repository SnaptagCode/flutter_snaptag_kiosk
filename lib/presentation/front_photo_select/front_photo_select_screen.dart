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
    _pageController = PageController(viewportFraction: 0.31, initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _moveToPage(int index) {
    SoundManager().playSound();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.25,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5.w),
          ),
          child: Icon(icon, size: 48.sp, color: Colors.white),
        ),
      ),
    );
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
          SizedBox(
            height: 500.h,
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
                : Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        // 카드 글로우/그림자가 페이지 경계에서 잘리지 않도록
                        clipBehavior: Clip.none,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          final photo = photos[index];
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              final page = _pageController.hasClients && _pageController.position.haveDimensions
                                  ? _pageController.page ?? _currentPage.toDouble()
                                  : _currentPage.toDouble();
                              final distance = (page - index).abs().clamp(0.0, 1.0);
                              final scale = 1.0 - distance * 0.12;
                              return Center(
                                child: Transform.scale(
                                  scale: scale,
                                  child: Opacity(opacity: 1.0 - distance * 0.15, child: child),
                                ),
                              );
                            },
                            child: SelectablePhotoCard(
                              width: 300.w,
                              height: 471.h,
                              index: index,
                              selectedIndex: selectedIndex,
                              imageFile: photo.embedImage,
                              imageUrl: photo.originUrl,
                              fit: BoxFit.cover,
                              showCheckBadge: true,
                              onTap: () {
                                SoundManager().playSound();
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
                      if (photos.length > 1) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 28.w),
                            child: _buildArrowButton(
                              icon: Icons.chevron_left_rounded,
                              enabled: _currentPage > 0,
                              onTap: () => _moveToPage(_currentPage - 1),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 28.w),
                            child: _buildArrowButton(
                              icon: Icons.chevron_right_rounded,
                              enabled: _currentPage < photos.length - 1,
                              onTap: () => _moveToPage(_currentPage + 1),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          SizedBox(height: 20.h),
          if (photos.length > 1 && photos.length <= 10)
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
            )
          else if (photos.length > 10)
            Text(
              '${_currentPage + 1} / ${photos.length}',
              style: isHwe
                  ? context.typography.vendingBody4B.copyWith(color: mainTextColor.withValues(alpha: 0.85))
                  : context.typography.kioskBody1B
                      .copyWith(fontSize: 24.sp, color: mainTextColor.withValues(alpha: 0.85)),
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

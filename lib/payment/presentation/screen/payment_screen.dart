// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/home/presentation/notifier/home_back_photo_type_notifier.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/price_box.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_notifier.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_state.dart';

/// 카드 선택 효과 시안 타입
enum SelectionDesignVariant {
  /// 시안 1: 투명도 + 카드 아래 체크 라디오 버튼
  opacityWithBottomRadio,

  /// 시안 2: 투명도 + 카드 위 우측 상단 체크 아이콘
  opacityWithTopRightCheck,

  /// 시안 3: 투명도 + 두꺼운 테두리 강조
  opacityWithBoldBorder,

  /// 시안 4: 투명도 + 중앙 오버레이 + 체크 아이콘
  opacityWithCenterOverlay,

  /// 시안 5: 투명도 + 카드 위 체크 아이콘 + 카드 아래 체크 라디오 버튼
  opacityWithTopCheckAndBottomRadio,

  /// 시안 6: 선택되지 않은 카드 크기 축소 + 애니메이션
  animatedScaleOnUnselected,
}

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
  });
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  /// 시안 6: 선택되지 않은 카드 크기 축소 + 애니메이션
  Widget _buildVariant6AnimatedScaleOnUnselected({
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    // 선택되지 않은 경우 크기를 0.85배로 축소
    final scale = selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.85);
    final opacity = selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _buildFixedBackPhotoCard(
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: buttonColor.withOpacity(0.4),
                      blurRadius: 12.r,
                      spreadRadius: 2.r,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
            imageUrl: imageUrl,
          ),
        ),
      ),
    );
  }

  Widget _buildFixedBackPhotoCard({
    required List<BoxShadow>? boxShadow,
    required String? imageUrl,
  }) {
    return Container(
      width: 226.w,
      height: 355.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: null,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: imageUrl != null && imageUrl.isNotEmpty ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.fitHeight,
      alignment: Alignment.center,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildEmptyImagePlaceholder(),
    );
  }

  Widget _buildEmptyImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildFixedBackPhotoCardList({
    required KioskMachineInfo? kiosk,
    required bool isFixed,
    required int? selectedIndex,
  }) {
    final nominatedBackPhotoCardList = kiosk?.nominatedBackPhotoCardList ?? [];
    if (kiosk == null || nominatedBackPhotoCardList.isEmpty) return _buildEmptyImagePlaceholder();

    return isFixed
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (nominatedBackPhotoCardList.length == 1)
                _buildFixedBackPhotoCard(boxShadow: null, imageUrl: nominatedBackPhotoCardList[0].originUrl)
              else
                _buildVariant6AnimatedScaleOnUnselected(
                  index: 0,
                  selectedIndex: selectedIndex,
                  imageUrl: nominatedBackPhotoCardList[0].originUrl,
                  onTap: () {
                    ref.read(backPhotoTypeNotifierProvider.notifier).selectFixed(0);
                  },
                ),
              if (nominatedBackPhotoCardList.length > 1) SizedBox(width: 100.w),
              if (nominatedBackPhotoCardList.length > 1)
                _buildVariant6AnimatedScaleOnUnselected(
                  index: 1,
                  selectedIndex: selectedIndex,
                  imageUrl: nominatedBackPhotoCardList[1].originUrl,
                  onTap: () {
                    ref.read(backPhotoTypeNotifierProvider.notifier).selectFixed(1);
                  },
                ),
            ],
          )
        : ref.watch(backPhotoSessionProvider).when(
              data: (data) {
                final imageUrl = data?.formattedBackPhotoCardUrl ?? '';
                return imageUrl.isNotEmpty
                    ? _buildFixedBackPhotoCard(boxShadow: null, imageUrl: imageUrl)
                    : _buildEmptyImagePlaceholder();
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => GeneralErrorWidget(
                exception: error as Exception,
                onRetry: () => ref.refresh(backPhotoSessionProvider),
              ),
            );
  }

  @override
  Widget build(BuildContext context) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final selection = ref.watch(backPhotoTypeNotifierProvider);
    final isHwe = kiosk?.isHwe ?? false;
    final isFixed = selection?.type == BackPhotoType.fixed;
    final selectedIndex = selection?.fixedIndex;
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isFixed &&
                          kiosk?.nominatedBackPhotoCardList.length != null &&
                          kiosk!.nominatedBackPhotoCardList.length > 1
                      ? LocaleKeys.choice_select_recommended_image.tr()
                      : LocaleKeys.sub02_txt_02.tr(),
                  textAlign: TextAlign.center,
                  style: isHwe
                      ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                      : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
                ),
                SizedBox(height: 50.h),
                _buildFixedBackPhotoCardList(kiosk: kiosk, isFixed: isFixed, selectedIndex: selectedIndex),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const PriceBox(),
                    SizedBox(width: 20.w),
                    Consumer(
                      builder: (context, ref, child) {
                        final isLoading = ref.watch(paymentNotifierProvider) is PaymentStateLoading;

                        return ElevatedButton(
                          style: context.paymentButtonStyle,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  await SoundManager().playSound();
                                  ref.read(paymentNotifierProvider.notifier).pay();
                                },
                          child: Text(LocaleKeys.sub02_btn_pay.tr(),
                              style: isHwe
                                  ? context.typography.vendingBtn2B
                                      .copyWith(color: (kiosk?.buttonTextColor ?? '').toColor(fallback: Colors.white))
                                  : context.typography.kioskBtn1B
                                      .copyWith(color: (kiosk?.buttonTextColor ?? '').toColor(fallback: Colors.white))),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Text(
                  LocaleKeys.sub03_txt_03.tr(),
                  style: isHwe
                      ? context.typography.vendingBody2B
                          .copyWith(color: (kiosk?.couponTextColor ?? '').toColor(fallback: Colors.white))
                      : context.typography.kioskBody2B.copyWith(
                          color: (kiosk?.couponTextColor ?? '').toColor(fallback: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

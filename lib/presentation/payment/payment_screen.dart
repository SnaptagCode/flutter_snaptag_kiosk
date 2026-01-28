// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_failed_type.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_failure_provider.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/verify_photo_card_provider.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/gradient_container.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/price_box.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/photo_card_preview_screen_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/update_order_info_state.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
  SelectionDesignVariant _currentVariant = SelectionDesignVariant.animatedScaleOnUnselected;
  bool _showTabs = false;

  /// 시안별 카드 빌더 라우터
  Widget _buildFixedBackPhotoCard({
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    switch (_currentVariant) {
      case SelectionDesignVariant.opacityWithBottomRadio:
        return _buildVariant1OpacityWithBottomRadio(
          index: index,
          selectedIndex: selectedIndex,
          imageUrl: imageUrl,
          onTap: onTap,
        );
      case SelectionDesignVariant.opacityWithTopRightCheck:
        return _buildVariant2OpacityWithTopRightCheck(
          index: index,
          selectedIndex: selectedIndex,
          imageUrl: imageUrl,
          onTap: onTap,
        );
      case SelectionDesignVariant.opacityWithBoldBorder:
        return _buildVariant3OpacityWithBoldBorder(
          index: index,
          selectedIndex: selectedIndex,
          imageUrl: imageUrl,
          onTap: onTap,
        );
      case SelectionDesignVariant.opacityWithCenterOverlay:
        return _buildVariant4OpacityWithCenterOverlay(
          index: index,
          selectedIndex: selectedIndex,
          imageUrl: imageUrl,
          onTap: onTap,
        );
      case SelectionDesignVariant.opacityWithTopCheckAndBottomRadio:
        return _buildVariant5OpacityWithTopCheckAndBottomRadio(
          index: index,
          selectedIndex: selectedIndex,
          imageUrl: imageUrl,
          onTap: onTap,
        );
      case SelectionDesignVariant.animatedScaleOnUnselected:
        return _buildVariant6AnimatedScaleOnUnselected(
          index: index,
          selectedIndex: selectedIndex,
          imageUrl: imageUrl,
          onTap: onTap,
        );
    }
  }

  /// 시안 1: 투명도 + 카드 아래 체크 라디오 버튼
  Widget _buildVariant1OpacityWithBottomRadio({
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: selectedIndex == null ? 1.2 : (isSelected ? 1.2 : 0.7),
            child: Container(
              width: 226.w,
              height: 355.h,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: imageUrl != null ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
            ),
          ),
          SizedBox(height: 12.h),
          // 체크 라디오 버튼
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? buttonColor : Colors.grey[300],
              border: Border.all(
                color: isSelected ? buttonColor : (Colors.grey[400] ?? Colors.grey),
                width: 2.w,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24.sp,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  /// 시안 2: 투명도 + 카드 위 우측 상단 체크 아이콘
  Widget _buildVariant2OpacityWithTopRightCheck({
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Opacity(
            opacity: selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.3),
            child: Container(
              width: 226.w,
              height: 355.h,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: imageUrl != null ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
            ),
          ),
          // 우측 상단 체크 아이콘
          if (isSelected)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: buttonColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 시안 3: 투명도 + 두꺼운 테두리 강조
  Widget _buildVariant3OpacityWithBoldBorder({
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.3),
        child: Container(
          width: 226.w,
          height: 355.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? buttonColor : Colors.transparent,
              width: isSelected ? 4.w : 0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: buttonColor.withOpacity(0.4),
                      blurRadius: 12.r,
                      spreadRadius: 2.r,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : null,
          ),
          child: imageUrl != null ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
        ),
      ),
    );
  }

  /// 시안 4: 투명도 + 중앙 오버레이 + 체크 아이콘
  Widget _buildVariant4OpacityWithCenterOverlay({
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Opacity(
            opacity: selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.3),
            child: Container(
              width: 226.w,
              height: 355.h,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: imageUrl != null ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
            ),
          ),
          // 중앙 오버레이 + 체크 아이콘
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: buttonColor.withOpacity(0.25),
                ),
                child: Center(
                  child: Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: buttonColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 36.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 시안 5: 투명도 + 카드 위 체크 라디오 버튼 (1번 시안의 대칭)
  Widget _buildVariant5OpacityWithTopCheckAndBottomRadio({
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 체크 라디오 버튼 (카드 위)
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? buttonColor : Colors.grey[300],
              border: Border.all(
                color: isSelected ? buttonColor : (Colors.grey[400] ?? Colors.grey),
                width: 2.w,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24.sp,
                  )
                : null,
          ),
          SizedBox(height: 12.h),
          // 카드
          Opacity(
            opacity: selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.5),
            child: Container(
              width: 226.w,
              height: 355.h,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: imageUrl != null ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

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
          child: Container(
            width: 226.w,
            height: 355.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.r),
              border: null,
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
            ),
            child: imageUrl != null ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
          ),
        ),
      ),
    );
  }

  /// 네트워크 이미지 위젯 빌더 (공통 빌더 포함)
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

  /// 빈 이미지 플레이스홀더
  Widget _buildEmptyImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
      ),
    );
  }

  /// 탭 토글 버튼
  Widget _buildTabToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showTabs = !_showTabs;
        });
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.transparent, // 투명하게
          shape: BoxShape.circle,
        ),
        child: Icon(
          _showTabs ? Icons.close : Icons.tune,
          color: Colors.transparent, // 투명하게
          size: 24.sp,
        ),
      ),
    );
  }

  /// 시안 선택 탭 UI
  Widget _buildDesignVariantTabs() {
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.transparent, // 투명하게
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.transparent, width: 1.w), // 투명하게
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVariantTab(
            label: '시안 1',
            variant: SelectionDesignVariant.opacityWithBottomRadio,
            buttonColor: buttonColor,
          ),
          SizedBox(width: 8.w),
          _buildVariantTab(
            label: '시안 2',
            variant: SelectionDesignVariant.opacityWithTopRightCheck,
            buttonColor: buttonColor,
          ),
          SizedBox(width: 8.w),
          _buildVariantTab(
            label: '시안 3',
            variant: SelectionDesignVariant.opacityWithBoldBorder,
            buttonColor: buttonColor,
          ),
          SizedBox(width: 8.w),
          _buildVariantTab(
            label: '시안 4',
            variant: SelectionDesignVariant.opacityWithCenterOverlay,
            buttonColor: buttonColor,
          ),
          SizedBox(width: 8.w),
          _buildVariantTab(
            label: '시안 5',
            variant: SelectionDesignVariant.opacityWithTopCheckAndBottomRadio,
            buttonColor: buttonColor,
          ),
          SizedBox(width: 8.w),
          _buildVariantTab(
            label: '시안 6',
            variant: SelectionDesignVariant.animatedScaleOnUnselected,
            buttonColor: buttonColor,
          ),
        ],
      ),
    );
  }

  /// 개별 시안 탭 버튼
  Widget _buildVariantTab({
    required String label,
    required SelectionDesignVariant variant,
    required Color buttonColor,
  }) {
    final isSelected = _currentVariant == variant;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentVariant = variant;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? buttonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.transparent, // 투명하게
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      photoCardPreviewScreenProviderProvider,
      (previous, next) async {
        final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);

        // 로딩 상태 처리
        if (next.isLoading) {
          if (mounted) {
            context.loaderOverlay.show();
          }
          return;
        }

        // 로딩 오버레이 숨기기
        if (mounted && context.loaderOverlay.visible) {
          context.loaderOverlay.hide();
        }

        // 에러/성공 처리
        await next.when(
          error: (error, stack) async {
            if (mounted) {
              timeoutNotifier.resumeTimer();
            }

            if (error is PaymentFailedException) {
              if (error is TimeoutPaymentException) {
                await DialogHelper.showTimeoutPaymentDialog(
                  context,
                );
                return;
              }
              if (error.description?.contains('한도') ?? false) {
                await DialogHelper.showCardLimitExceededDialog(
                  context,
                );
                return;
              }
              if (error.description?.contains('잔액') ?? false) {
                await DialogHelper.showInsufficientBalanceDialog(
                  context,
                );
                return;
              }
              if (error.description?.contains('인증') ?? false) {
                await DialogHelper.showVerificationErrorDialog(
                  context,
                );
                return;
              }
              if (error.description?.contains('가맹점') ?? false) {
                await DialogHelper.showMerchantRestrictionDialog(
                  context,
                );
                return;
              }
            }

            await DialogHelper.showPurchaseFailedDialog(
              context,
            );
            return;
          },
          loading: () => null,
          data: (_) async {
            // 결제 성공 시 출력 화면으로 이동
            PrintProcessRouteData().go(context);
          },
        );
      },
    );
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final selection = ref.watch(backPhotoTypeProvider);
    final isFixed = selection?.type == BackPhotoType.fixed;
    final selectedIndex = selection?.fixedIndex;
    final mainTextColor =
        kiosk?.mainTextColor != null ? Color(int.parse(kiosk!.mainTextColor.replaceFirst('#', '0xff'))) : Colors.white;

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
                  isFixed ? LocaleKeys.choice_select_recommended_image.tr() : LocaleKeys.sub02_txt_01.tr(),
                  textAlign: TextAlign.center,
                  style: context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
                ),
                SizedBox(height: 50.h),
                if (isFixed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFixedBackPhotoCard(
                        index: 0,
                        selectedIndex: selectedIndex,
                        imageUrl: kiosk?.nominatedBackPhotoCardList.isNotEmpty == true &&
                                (kiosk!.nominatedBackPhotoCardList.isNotEmpty)
                            ? kiosk.nominatedBackPhotoCardList[0].originUrl
                            : null,
                        onTap: () {
                          ref.read(backPhotoTypeProvider.notifier).selectFixed(0);
                        },
                      ),
                      SizedBox(width: 100.w),
                      _buildFixedBackPhotoCard(
                        index: 1,
                        selectedIndex: selectedIndex,
                        imageUrl: kiosk?.nominatedBackPhotoCardList.isNotEmpty == true &&
                                (kiosk!.nominatedBackPhotoCardList.length > 1)
                            ? kiosk.nominatedBackPhotoCardList[1].originUrl
                            : null,
                        onTap: () {
                          ref.read(backPhotoTypeProvider.notifier).selectFixed(1);
                        },
                      ),
                    ],
                  )
                else
                  GradientContainer(
                    content: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: ref.watch(verifyPhotoCardProvider).when(
                            data: (data) {
                              final imageUrl = data?.formattedBackPhotoCardUrl ?? '';
                              return imageUrl.isNotEmpty ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder();
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) => GeneralErrorWidget(
                              exception: error as Exception,
                              onRetry: () => ref.refresh(verifyPhotoCardProvider),
                            ),
                          ),
                    ),
                  ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const PriceBox(),
                    SizedBox(width: 20.w),
                    Consumer(
                      builder: (context, ref, child) {
                        final paymentState = ref.watch(photoCardPreviewScreenProviderProvider);
                        final isLoading = paymentState.isLoading;

                        return ElevatedButton(
                          style: context.paymentButtonStyle,
                          onPressed: isLoading
                              ? null // 로딩 중일 때 버튼 비활성화
                              : () async {
                                  await SoundManager().playSound();

                                  // // 선택된 뒷면 이미지 타입 확인
                                  final selection = ref.read(backPhotoTypeProvider);

                                  if (selection?.type == BackPhotoType.fixed && selection?.fixedIndex != null) {
                                    // 고정 뒷면 이미지 결제 처리
                                    final kiosk = ref.read(kioskInfoServiceProvider);
                                    final selectedIndex = selection!.fixedIndex!;

                                    if (kiosk != null && selectedIndex < kiosk.nominatedBackPhotoCardList.length) {
                                      final selectedCard = kiosk.nominatedBackPhotoCardList[selectedIndex];

                                      final response = await ref.read(kioskRepositoryProvider).getBackPhotoCardByQr(
                                            GetBackPhotoByQrRequest(
                                              kioskEventId: kiosk.kioskEventId,
                                              nominatedBackPhotoCardId: selectedCard.id,
                                            ),
                                          );

                                      ref.read(verifyPhotoCardProvider.notifier).updateState(BackPhotoCardResponse(
                                          kioskEventId: kiosk.kioskEventId,
                                          backPhotoCardId: response.backPhotoCardId,
                                          backPhotoCardOriginUrl: selectedCard.originUrl,
                                          photoAuthNumber: response.photoAuthNumber,
                                          formattedBackPhotoCardUrl: response.formattedBackPhotoCardUrl));
                                    }
                                  }

                                  final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);
                                  timeoutNotifier.cancelTimerWithCallback();

                                  await ref.read(photoCardPreviewScreenProviderProvider.notifier).payment();
                                  final isPaymentFailed = ref.read(paymentFailureProvider);
                                  if (isPaymentFailed) {
                                    ref.read(paymentFailureProvider.notifier).reset();
                                    DialogHelper.showPaymentCardFailedDialog(
                                      context,
                                    );
                                    HomeRouteData().go(context);
                                  }
                                },
                          child: Text(LocaleKeys.sub02_btn_pay.tr()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Text(
                  LocaleKeys.sub03_txt_03.tr(),
                  style: context.typography.kioskBody2B.copyWith(
                    color: Color(int.parse(kiosk?.couponTextColor.replaceFirst('#', '0xff') ?? '0xffffff')),
                    //fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
          // 오른쪽 상단 탭 토글 버튼 및 탭 UI (캡처를 위해 투명 처리, 클릭은 가능)
          if (isFixed)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                color: Colors.transparent, // 투명 배경
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // _buildTabToggleButton(),
                    // if (_showTabs) ...[
                    //   SizedBox(height: 8.h),
                    //   _buildDesignVariantTabs(),
                    // ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

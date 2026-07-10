// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/price_box.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_failed_type.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/photo_card_preview_screen_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/verify_photo_card_provider.dart';
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
  bool _isNetworkErrorHandled = false;

  Widget _buildFixedBackPhotoCard({
    required List<BoxShadow>? boxShadow,
    required String? imageUrl,
    bool hasBorder = false,
  }) {
    return Container(
      width: 226.w,
      height: 355.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: hasBorder ? Border.all(color: Colors.white, width: 1.w) : null,
        boxShadow: hasBorder
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 4.r,
                  spreadRadius: 1.r,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 12.r,
                  spreadRadius: 3.r,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 28.r,
                  spreadRadius: 6.r,
                ),
              ]
            : boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: imageUrl != null && imageUrl.isNotEmpty ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
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

  Widget _buildFixedBackPhotoCardList({
    required KioskMachineInfo? kiosk,
    required bool isFixed,
    required int? selectedIndex,
  }) {
    final nominatedBackPhotoCardList = kiosk?.nominatedBackPhotoCardList ?? [];
    if (kiosk == null || nominatedBackPhotoCardList.isEmpty) return _buildEmptyImagePlaceholder();

    if (!isFixed) {
      return ref.watch(verifyPhotoCardProvider).when(
            data: (data) {
              final imageUrl = data?.formattedBackPhotoCardUrl ?? '';
              return imageUrl.isNotEmpty
                  ? _buildFixedBackPhotoCard(boxShadow: null, imageUrl: imageUrl)
                  : _buildEmptyImagePlaceholder();
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => GeneralErrorWidget(
              exception: error as Exception,
              onRetry: () => ref.refresh(verifyPhotoCardProvider),
            ),
          );
    }

    // 뒷면 이미지 썸네일 목록 1차 선택
    final int selected = (selectedIndex ?? 0).clamp(0, nominatedBackPhotoCardList.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nominatedBackPhotoCardList.length > 1) ...[
          // _buildStepLabel(LocaleKeys.choice_step1_select_image.tr()),
          // SizedBox(height: 14.h),
          _buildImageThumbnailStrip(nominatedBackPhotoCardList, selected),
          // SizedBox(height: 34.h),
          // _buildStepLabel(LocaleKeys.choice_step2_select_style.tr()),
          // SizedBox(height: 14.h),
        ],
        _buildStyleStep(card: nominatedBackPhotoCardList[selected]),
      ],
    );
  }

  /// 풀이미지가 1장 이상일시 목록 선택형으로 진행
  Widget _buildImageThumbnailStrip(List<NominatedBackPhotoCard> cards, int selectedIndex) {
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);
    final double thumbHeight = 170.h;
    final double thumbWidth = thumbHeight * 650 / 1023; // ?ㅻЪ ?ы넗移대뱶 鍮꾩쑉

    return SizedBox(
      height: thumbHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        itemCount: cards.length,
        separatorBuilder: (_, __) => SizedBox(width: 24.w),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => ref.read(backPhotoTypeProvider.notifier).selectFixed(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: thumbWidth,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? buttonColor : Colors.white.withValues(alpha: 0.35),
                  width: isSelected ? 3.w : 1.w,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: buttonColor.withValues(alpha: 0.45),
                          blurRadius: 10.r,
                          spreadRadius: 1.r,
                        ),
                      ]
                    : null,
              ),
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.55,
                child: _buildCoverNetworkImage(cards[index].originUrl),
              ),
            ),
          );
        },
      ),
    );
  }

  Color get _mainTextColor {
    final kiosk = ref.read(kioskInfoServiceProvider);
    return kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;
  }

  Widget _buildStepLabel(String text) {
    return Text(
      text,
      style: context.typography.kioskBody2B.copyWith(color: _mainTextColor),
    );
  }

  Widget _buildStyleStep({required NominatedBackPhotoCard card}) {
    final layout = ref.watch(backPhotoTypeProvider)?.layoutType;
    // 라벨 이미지, 풀이미지 선택
    final selectedStyleIndex = layout == BackPhotoLayoutType.full ? 1 : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 카드 미리보기
        // Text(
        //   LocaleKeys.choice_back_side_notice.tr(),
        //   style: context.typography.kioskBody2B.copyWith(color: _mainTextColor.withValues(alpha: 0.85)),
        // ),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStyleCard(
              index: 0,
              selectedIndex: selectedStyleIndex,
              card: _buildLabeledPreviewCard(card.originUrl),
              onTap: () => ref.read(backPhotoTypeProvider.notifier).selectLayout(BackPhotoLayoutType.labeled),
            ),
            SizedBox(width: 100.w),
            _buildStyleCard(
              index: 1,
              selectedIndex: selectedStyleIndex,
              card: _buildFullPreviewCard(card.originUrl),
              onTap: () => ref.read(backPhotoTypeProvider.notifier).selectLayout(BackPhotoLayoutType.full),
            ),
          ],
        ),
      ],
    );
  }

  /// 실제 포토카드 비율에 맞는 UI 크기 조젇
  /// 전체크기 650*1023 상단 라벨위치 y: 0~80/ 하단 라벨 위치 y: 943~1023 (650 * 80)
  Widget _buildLabeledPreviewCard(String imageUrl) {
    final kiosk = ref.read(kioskInfoServiceProvider);
    final eventName = kiosk?.printedEventName ?? '';
    final now = DateTime.now();
    final dateText = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    final double cardHeight = 355.h;
    final double bandHeight = cardHeight * 80 / 1023; // ?ㅻЪ ?쇰꺼 諛대뱶 80px 鍮꾨?

    return Container(
      width: 226.w,
      height: cardHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Container(
            height: bandHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              eventName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _labelFontFamily,
                fontSize: bandHeight * 0.5,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: _buildCoverNetworkImage(imageUrl),
            ),
          ),
          Container(
            height: bandHeight,
            alignment: Alignment.center,
            child: Text(
              dateText,
              style: TextStyle(
                fontFamily: _labelFontFamily,
                fontSize: bandHeight * 0.45,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 포토카드 라벨 글꼴: 한화(HWEG) HanwhaEagles-Regular
  /// 일본어 KeinanMugimaruJP, 기본 Cafe24Ssurround v2.
  String get _labelFontFamily {
    if (ref.read(kioskInfoServiceProvider)?.isHwe ?? false) return 'Hanwha';
    if (context.locale.languageCode == 'ja') return 'KeinanMugimaruJP';
    return 'Cafe24Ssurround2';
  }

  /// 풀스크린 이미지
  Widget _buildFullPreviewCard(String imageUrl) {
    return Container(
      width: 226.w,
      height: 355.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
      child: _buildCoverNetworkImage(imageUrl),
    );
  }

  Widget _buildCoverNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
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
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => _buildEmptyImagePlaceholder(),
    );
  }

  Widget _buildStyleCard({
    required int index,
    required int selectedIndex,
    required Widget card,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.85,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: buttonColor.withValues(alpha: 0.4),
                        blurRadius: 12.r,
                        spreadRadius: 2.r,
                        offset: Offset(0, 4.h),
                      ),
                    ]
                  : null,
            ),
            child: card,
          ),
        ),
      ),
    );
  }

  String _titleText(KioskMachineInfo? kiosk, bool isFixed) {
    final cards = kiosk?.nominatedBackPhotoCardList ?? [];
    if (isFixed && cards.isNotEmpty) return LocaleKeys.choice_select_print_style.tr();
    return LocaleKeys.sub02_txt_02.tr();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NetworkState>(networkStatusNotifierProvider, (previous, next) {
      if (_isNetworkErrorHandled) return;
      if (previous?.status == next.status) return;

      final isNetworkDown = next.status == NetworkStatus.disconnected || next.status == NetworkStatus.unstable;
      if (!isNetworkDown) return;
      if (!ref.read(photoCardPreviewScreenProviderProvider).isLoading) return;

      _isNetworkErrorHandled = true;

      if (!mounted) return;
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      DialogHelper.showKioskDialog(
        context,
        title: LocaleKeys.alert_title_network_error.tr(),
        contentText: LocaleKeys.alert_txt_print_network_error.tr(),
        confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
      ).then((_) {
        if (mounted) HomeRouteData().go(context);
      });
    });

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
            if (_isNetworkErrorHandled) return;

            if (mounted) {
              timeoutNotifier.resumeTimer();
            }

            final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
            SlackLogService().sendLogToSlack('*[MachineId : $machineId]* Payment process failed: $error');

            // 결제 승인 후 후속 처리 실패로 자동환불을 탄 경우 → 환불 결과를 사용자에게 안내한다.
            if (error is PostPaymentRefundException) {
              final refundResult = error.refundResult;
              if (!mounted) return;
              if (refundResult is RefundSuccess) {
                await DialogHelper.showAutoRefundSuccessDialog(
                  context,
                  amount: refundResult.amount,
                  autoCloseDuration: const Duration(seconds: 5),
                );
              } else {
                // 환불 실패(결제됐으나 환불 안 됨, 돈이 묶임) → 직원 문의 안내, 확인 필수
                await DialogHelper.showAutoRefundFailedDialog(context);
              }
              if (mounted) HomeRouteData().go(context);
              return;
            }

            if (error.toString().contains('Card feeder is empty')) {
              await DialogHelper.showPrintCardRefillDialog(
                context,
              );
              return;
            }

            if (error is PaymentPreparationException) {
              await DialogHelper.showPaymentPreparationFailedDialog(
                context,
              );
              return;
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
                  _titleText(kiosk, isFixed),
                  textAlign: TextAlign.center,
                  style: isHwe
                      ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                      : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
                ),
                SizedBox(height: 20.h),
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
                        final paymentState = ref.watch(photoCardPreviewScreenProviderProvider);
                        final isLoading = paymentState.isLoading;

                        return ElevatedButton(
                          style: context.paymentButtonStyle,
                          onPressed: isLoading
                              ? null // 로딩 중일 때 버튼 비활성화
                              : () async {
                                  await SoundManager().playSound();

                                  await ref.read(photoCardPreviewScreenProviderProvider.notifier).payment();
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

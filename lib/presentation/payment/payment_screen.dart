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

/// 선택 강조 모션 값. 썸네일/스타일 카드가 같은 리듬으로 움직이도록 공유한다.
class _SelectionMotion {
  const _SelectionMotion._();

  static const Duration duration = Duration(milliseconds: 180);
  static const Curve curve = Curves.easeOutCubic;

  /// 체크 배지는 살짝 튕기며 등장한다.
  static const Curve badgeCurve = Curves.easeOutBack;
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

    // 출력 스타일(라벨/풀이미지) 선택은 한화(HWEG) 전용. 그 외 업체는 기존 카드 선택 UI 유지 (JKLI-214)
    if (!kiosk.isHwe) return _buildLegacyFixedCards(nominatedBackPhotoCardList, selectedIndex);

    // 뒷면 이미지 썸네일 목록 1차 선택
    final int selected = (selectedIndex ?? 0).clamp(0, nominatedBackPhotoCardList.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nominatedBackPhotoCardList.length > 1) _buildImageThumbnailStrip(nominatedBackPhotoCardList, selected),
        SizedBox(height: 24.h),
        _buildStyleStep(card: nominatedBackPhotoCardList[selected]),
      ],
    );
  }

  /// 한화 외 업체의 고정 뒷면 선택 UI — 추천 이미지 카드를 그대로 나란히 놓는다.
  /// 1장이면 네온 테두리만, 2장 이상이면 앞의 두 장을 선택형으로 노출한다 (JKLI-110 이전 동작).
  Widget _buildLegacyFixedCards(List<NominatedBackPhotoCard> cards, int? selectedIndex) {
    if (cards.length == 1) {
      return _buildFixedBackPhotoCard(boxShadow: null, imageUrl: cards[0].originUrl, hasBorder: true);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegacyFixedCard(index: 0, selectedIndex: selectedIndex, imageUrl: cards[0].originUrl),
        SizedBox(width: 100.w),
        _buildLegacyFixedCard(index: 1, selectedIndex: selectedIndex, imageUrl: cards[1].originUrl),
      ],
    );
  }

  Widget _buildLegacyFixedCard({
    required int index,
    required int? selectedIndex,
    required String imageUrl,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    return GestureDetector(
      onTap: () => ref.read(backPhotoTypeProvider.notifier).selectFixed(index),
      child: _SelectionTransition(
        // 아직 아무것도 고르지 않았으면 두 장 모두 원래 크기로 둔다.
        isSelected: selectedIndex == null || isSelected,
        unselectedScale: 0.85,
        unselectedOpacity: 0.6,
        child: _buildFixedBackPhotoCard(
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: buttonColor.withValues(alpha: 0.4),
                    blurRadius: 12.r,
                    spreadRadius: 2.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r, offset: Offset(0, 2.h)),
                ],
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  /// 풀이미지가 1장 이상일시 목록 선택형으로 진행
  Widget _buildImageThumbnailStrip(List<NominatedBackPhotoCard> cards, int selectedIndex) {
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);
    final double thumbSize = 118.h;
    // 선택 시 링/글로우가 이웃 썸네일에 닿지 않을 만큼의 간격
    final double thumbGap = 40.w;
    final double sidePadding = 24.w;

    return SizedBox(
      // 링/글로우가 위아래로 잘리지 않도록 확보하는 여백
      height: thumbSize + 28.h,
      child: Center(
        // shrinkWrap + Center: 개수가 적으면 가운데 모이고, 넘치면 스크롤된다.
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          itemCount: cards.length,
          separatorBuilder: (_, __) => SizedBox(width: thumbGap),
          itemBuilder: (context, index) {
            // 가로 ListView는 교차축을 tight하게 강제한다. Center로 감싸지 않으면
            // 아이템이 스트립 높이만큼 세로로 늘어난다.
            return Center(
              child: _buildThumbnailItem(
                card: cards[index],
                index: index,
                selectedIndex: selectedIndex,
                buttonColor: buttonColor,
                size: thumbSize,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThumbnailItem({
    required NominatedBackPhotoCard card,
    required int index,
    required int selectedIndex,
    required Color buttonColor,
    required double size,
  }) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => ref.read(backPhotoTypeProvider.notifier).selectFixed(index),
      child: _SelectionTransition(
        isSelected: isSelected,
        unselectedScale: 0.9,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            // 배지가 튕기며 커질 때(easeOutBack 오버슈트) 모서리가 잘리지 않게 한다.
            clipBehavior: Clip.none,
            children: [
              _SelectionRing(
                isSelected: isSelected,
                color: buttonColor,
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCoverNetworkImage(card.originUrl),
                      AnimatedOpacity(
                        opacity: isSelected ? 0.0 : 0.45,
                        duration: _SelectionMotion.duration,
                        curve: _SelectionMotion.curve,
                        child: const ColoredBox(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              // 배지는 원 안쪽을 가리지 않도록 우하단 모서리에 걸친다.
              Positioned(
                right: 0,
                bottom: 0,
                child: _SelectionCheckBadge(
                  visible: isSelected,
                  size: 30.w,
                  color: buttonColor,
                ),
              ),
            ],
          ),
        ),
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
    // 라벨 이미지가 기본값 (미선택 = null 도 라벨로 취급, 서버 기본값과 동일)
    final selectedStyleIndex = layout == BackPhotoLayoutType.full ? 1 : 0;

    return Row(
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

    // 카드 모서리(10.r)에 링 두께와 간격을 더해야 링이 카드와 동심원으로 보인다.
    final outerRadius = BorderRadius.circular(10.r + _SelectionRing.inset);

    return GestureDetector(
      onTap: onTap,
      child: _SelectionTransition(
        isSelected: isSelected,
        unselectedScale: 0.92,
        unselectedOpacity: 0.68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _SelectionRing(
              isSelected: isSelected,
              color: buttonColor,
              borderRadius: outerRadius,
              // 비선택 카드도 배경 사진 위에서 떠 보이도록 옅은 그림자를 남긴다.
              restShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r, offset: Offset(0, 2.h)),
              ],
              child: card,
            ),
            Positioned(
              right: 12.w,
              bottom: 12.h,
              child: _SelectionCheckBadge(
                visible: isSelected,
                size: 40.w,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleText(KioskMachineInfo? kiosk, bool isFixed) {
    final cards = kiosk?.nominatedBackPhotoCardList ?? [];

    // 커스텀(나만의 포토카드)은 추천 이미지가 아니므로 '포토카드 이미지 확인하기'
    if (!isFixed || cards.isEmpty) return LocaleKeys.sub02_txt_01.tr();

    // 한화만 출력 스타일 선택 단계가 있다.
    if (kiosk?.isHwe ?? false) return LocaleKeys.choice_select_print_style.tr();

    return cards.length > 1 ? LocaleKeys.choice_select_recommended_image.tr() : LocaleKeys.sub02_txt_02.tr();
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
    final couponTextColor = (kiosk?.couponTextColor ?? '').toColor(fallback: Colors.white);

    // 한화의 출력 스타일 단계는 세로로 길어서 타이틀 간격을 줄인다.
    final hasStyleStep = isFixed && isHwe && (kiosk?.nominatedBackPhotoCardList.isNotEmpty ?? false);

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
                SizedBox(height: hasStyleStep ? 20.h : 50.h),
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
                SizedBox(height: 30.h),
                Text(
                  LocaleKeys.sub03_txt_03.tr(),
                  textAlign: TextAlign.center,
                  style: isHwe
                      ? context.typography.vendingBody2B.copyWith(color: couponTextColor)
                      : context.typography.kioskBody2B.copyWith(color: couponTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 선택/비선택을 크기와 투명도로 함께 전환하는 공용 애니메이터.
///
/// 화면 내 선택 UI(썸네일, 스타일 카드)가 모두 이 위젯을 쓴다.
/// 암시적 애니메이션이라 부모가 리빌드돼도 진행 중인 전환이 끊기지 않는다.
/// (AnimatedSwitcher처럼 key로 서브트리를 갈아끼우면 Image.network가 매번
/// 새로 붙고 이전/다음 카드가 겹쳐 보인다.)
class _SelectionTransition extends StatelessWidget {
  const _SelectionTransition({
    required this.isSelected,
    required this.child,
    this.unselectedScale = 0.92,
    this.unselectedOpacity = 1.0,
  });

  final bool isSelected;
  final Widget child;

  /// 비선택 시 축소 배율
  final double unselectedScale;

  /// 비선택 시 투명도. 1.0이면 투명도는 건드리지 않는다.
  final double unselectedOpacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.0 : unselectedScale,
      duration: _SelectionMotion.duration,
      curve: _SelectionMotion.curve,
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : unselectedOpacity,
        duration: _SelectionMotion.duration,
        curve: _SelectionMotion.curve,
        child: child,
      ),
    );
  }
}

/// 선택된 항목을 감싸는 링 + 글로우.
///
/// 원형(썸네일)과 라운드 사각(스타일 카드)이 같은 강조 언어를 쓰도록 공용화했다.
/// [borderRadius]가 null이면 원형으로 그린다.
class _SelectionRing extends StatelessWidget {
  const _SelectionRing({
    required this.isSelected,
    required this.color,
    required this.child,
    this.borderRadius,
    this.restShadow,
  });

  final bool isSelected;
  final Color color;
  final Widget child;
  final BorderRadius? borderRadius;

  /// 비선택 상태에서 유지할 그림자. null이면 그림자 없음.
  final List<BoxShadow>? restShadow;

  static double get ringWidth => 3.w;
  static double get ringGap => 4.r;

  /// 링이 내용물 바깥으로 차지하는 두께 (테두리 + 간격)
  static double get inset => ringWidth + ringGap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _SelectionMotion.duration,
      curve: _SelectionMotion.curve,
      // 링 두께와 간격은 선택 여부와 무관하게 항상 자리를 차지해야
      // 내용물이 찌그러지거나 크기가 튀지 않는다.
      padding: EdgeInsets.all(ringGap),
      decoration: BoxDecoration(
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: ringWidth,
        ),
        // 이벤트 배경 사진 위에서도 선택이 드러나도록 링 바깥으로 번지게 한다.
        boxShadow: isSelected
            ? [
                BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 8.r),
                BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 20.r, spreadRadius: 2.r),
              ]
            : restShadow,
      ),
      child: child,
    );
  }
}

/// 선택된 항목에 튕기듯 나타나는 체크 배지.
class _SelectionCheckBadge extends StatelessWidget {
  const _SelectionCheckBadge({
    required this.visible,
    required this.size,
    required this.color,
  });

  final bool visible;
  final double size;

  /// 배지 바탕색(이벤트 테마의 buttonColor)
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.0,
      duration: _SelectionMotion.duration,
      curve: _SelectionMotion.badgeCurve,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.w),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6.r, offset: Offset(0, 2.h)),
          ],
        ),
        child: Icon(Icons.check_rounded, size: size * 0.55, color: Colors.white),
      ),
    );
  }
}

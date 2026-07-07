// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/price_box.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/selectable_photo_card.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/front_photo_select/selected_front_photo_provider.dart';
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

  /// 선택형: 선택 완료된 앞면 + 뒷면을 동일 크기로 나란히 확인 (JKLI-175)
  Widget _buildFrontBackConfirm({
    required KioskMachineInfo? kiosk,
    required int? selectedIndex,
    required NominatedPhoto front,
    required Color labelColor,
  }) {
    final backs = kiosk?.nominatedBackPhotoCardList ?? [];
    final backUrl = backs.isEmpty ? '' : backs[(selectedIndex ?? 0).clamp(0, backs.length - 1)].originUrl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledCard(
          label: LocaleKeys.front_photo_label.tr(),
          labelColor: labelColor,
          card: PhotoCardFrame(
            width: 260.w,
            height: 408.h,
            imageFile: front.embedImage,
            imageUrl: front.originUrl,
            fit: BoxFit.cover,
            hasBorder: true,
          ),
        ),
        SizedBox(width: 60.w),
        _buildLabeledCard(
          label: LocaleKeys.back_photo_label.tr(),
          labelColor: labelColor,
          card: PhotoCardFrame(width: 260.w, height: 408.h, imageUrl: backUrl, hasBorder: true),
        ),
      ],
    );
  }

  Widget _buildLabeledCard({required String label, required Color labelColor, required Widget card}) {
    final isHwe = ref.read(kioskInfoServiceProvider)?.isHwe ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        card,
        SizedBox(height: 16.h),
        Text(
          label,
          style: isHwe
              ? context.typography.vendingBody2B.copyWith(color: labelColor)
              : context.typography.kioskBody1B.copyWith(fontSize: 28.sp, color: labelColor),
        ),
      ],
    );
  }

  /// 뒷면 확인 카드 (선택은 뒷면 선택 화면에서 완료). 커스텀은 인증된 뒷면 1장.
  Widget _buildFixedBackPhotoCardList({
    required KioskMachineInfo? kiosk,
    required bool isFixed,
    required int? selectedIndex,
  }) {
    if (kiosk == null) return const PhotoCardEmptyPlaceholder();

    if (!isFixed) {
      return ref.watch(verifyPhotoCardProvider).when(
            data: (data) {
              final imageUrl = data?.formattedBackPhotoCardUrl ?? '';
              return imageUrl.isNotEmpty
                  ? PhotoCardFrame(width: 226.w, height: 355.h, imageUrl: imageUrl)
                  : const PhotoCardEmptyPlaceholder();
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => GeneralErrorWidget(
              exception: error as Exception,
              onRetry: () => ref.refresh(verifyPhotoCardProvider),
            ),
          );
    }

    final backs = kiosk.nominatedBackPhotoCardList;
    if (backs.isEmpty) return const PhotoCardEmptyPlaceholder();
    final url = backs[(selectedIndex ?? 0).clamp(0, backs.length - 1)].originUrl;
    return PhotoCardFrame(width: 226.w, height: 355.h, imageUrl: url, hasBorder: true);
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
    // 선택형: 사용자가 고른 앞면이 있으면 앞·뒷면을 함께 확인시킨다 (JKLI-175)
    final selectedFront = ref.watch(selectedFrontPhotoProvider);
    final showFrontBackConfirm = isFixed && selectedFront != null;

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
                  showFrontBackConfirm
                      ? LocaleKeys.front_back_confirm_title.tr()
                      : LocaleKeys.sub02_txt_02.tr(),
                  textAlign: TextAlign.center,
                  style: isHwe
                      ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                      : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
                ),
                SizedBox(height: 50.h),
                showFrontBackConfirm
                    ? _buildFrontBackConfirm(
                        kiosk: kiosk,
                        selectedIndex: selectedIndex,
                        front: selectedFront,
                        labelColor: mainTextColor,
                      )
                    : _buildFixedBackPhotoCardList(kiosk: kiosk, isFixed: isFixed, selectedIndex: selectedIndex),
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
                  style: isHwe
                      ? context.typography.vendingBody2B
                          .copyWith(color: (kiosk?.couponTextColor ?? '').toColor(fallback: Colors.white))
                      : context.typography.kioskBody2B.copyWith(
                          color: (kiosk?.couponTextColor ?? '').toColor(fallback: Colors.white),
                          //fontFamily: 'Pretendard',
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

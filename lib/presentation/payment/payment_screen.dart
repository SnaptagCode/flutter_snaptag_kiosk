// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_failed_type.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/photo_card_preview_screen_provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart' as p;

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
    required File? file,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

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
            file: file,
          ),
        ),
      ),
    );
  }

  static List<File> _getLocalBackPhotos() {
    final dir = Directory(p.join(p.dirname(Platform.resolvedExecutable), 'image', 'back_photos'));
    if (!dir.existsSync()) return [];
    return dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final lower = f.path.toLowerCase();
          return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
        })
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  Widget _buildFixedBackPhotoCard({
    required List<BoxShadow>? boxShadow,
    required File? file,
  }) {
    return Container(
      width: 226.w,
      height: 355.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: file != null ? Image.file(file, fit: BoxFit.fitHeight) : _buildEmptyImagePlaceholder(),
      ),
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

  Widget _buildLocalBackPhotoCardList({required int? selectedIndex}) {
    final files = _getLocalBackPhotos();
    if (files.isEmpty) return _buildEmptyImagePlaceholder();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < files.length; i++) ...[
            if (i > 0) SizedBox(width: 40.w),
            _buildVariant6AnimatedScaleOnUnselected(
              index: i,
              selectedIndex: selectedIndex,
              file: files[i],
              onTap: () => ref.read(backPhotoTypeProvider.notifier).selectFixed(i),
            ),
          ],
        ],
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

            SlackLogService().sendErrorLogToSlack('Payment process failed: $error');

            if (error.toString().contains('R600')) {
              await DialogHelper.showPrintErrorDialog(context);
              return;
            }

            if (error.toString().contains('Card feeder is empty')) {
              await DialogHelper.showPrintCardRefillDialog(context);
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
                _buildLocalBackPhotoCardList(selectedIndex: selectedIndex),
                SizedBox(height: 50.h),
                Consumer(
                  builder: (context, ref, child) {
                    final paymentState = ref.watch(photoCardPreviewScreenProviderProvider);
                    final isLoading = paymentState.isLoading;

                    return ElevatedButton(
                      style: context.paymentButtonStyle.copyWith(
                        fixedSize: WidgetStatePropertyAll(Size(380.w, 78.h)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              await SoundManager().playSound();
                              await ref.read(photoCardPreviewScreenProviderProvider.notifier).payment();
                            },
                      child: Text(LocaleKeys.choice_btn_print.tr(),
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
          ),
        ],
      ),
    );
  }
}

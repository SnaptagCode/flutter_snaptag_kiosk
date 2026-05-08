// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_failed_type.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/photo_card_preview_screen_provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart' as p;

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
  });
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  static File? _getDisplayPhoto() {
    final dir = Directory(p.join(p.dirname(Platform.resolvedExecutable), 'image', 'back_photos'));
    if (!dir.existsSync()) return null;
    final originFile = File(p.join(dir.path, 'origin_photo.png'));
    if (originFile.existsSync()) return originFile;
    final dateStr = DateFormat('yyMMdd').format(DateTime.now());
    return dir.listSync().whereType<File>().firstWhereOrNull((f) {
      final name = p.basenameWithoutExtension(f.path.toLowerCase());
      return name == dateStr;
    });
  }

  Widget _buildFixedBackPhotoCard({
    required List<BoxShadow>? boxShadow,
    required File? file,
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
        child: file != null ? Image.file(file, fit: BoxFit.fitHeight) : _buildEmptyImagePlaceholder(),
      ),
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      photoCardPreviewScreenProviderProvider,
      (previous, next) async {
        final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);

        if (next.isLoading) {
          if (mounted) {
            context.loaderOverlay.show();
          }
          return;
        }

        if (mounted && context.loaderOverlay.visible) {
          context.loaderOverlay.hide();
        }

        await next.when(
          error: (error, stack) async {
            if (mounted) {
              timeoutNotifier.resumeTimer();
            }

            if (error is BackPhotoNotFoundException) {
              if (mounted) {
                const HomeRouteData().go(context);
              }
              return;
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
                await DialogHelper.showTimeoutPaymentDialog(context);
                return;
              }
              if (error.description?.contains('한도') ?? false) {
                await DialogHelper.showCardLimitExceededDialog(context);
                return;
              }
              if (error.description?.contains('잔액') ?? false) {
                await DialogHelper.showInsufficientBalanceDialog(context);
                return;
              }
              if (error.description?.contains('인증') ?? false) {
                await DialogHelper.showVerificationErrorDialog(context);
                return;
              }
              if (error.description?.contains('가맹점') ?? false) {
                await DialogHelper.showMerchantRestrictionDialog(context);
                return;
              }
            }

            await DialogHelper.showPurchaseFailedDialog(context);
            return;
          },
          loading: () => null,
          data: (_) async {
            PrintProcessRouteData().go(context);
          },
        );
      },
    );
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final isHwe = kiosk?.isHwe ?? false;
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'PretendardJP' : 'Cafe24Ssurround2',
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.sub02_txt_02.tr(),
                  textAlign: TextAlign.center,
                  style: isHwe
                      ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                      : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
                ),
                SizedBox(height: 50.h),
                _buildFixedBackPhotoCard(
                  boxShadow: null,
                  file: _getDisplayPhoto(),
                  hasBorder: true,
                ),
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
                          style: context.locale.languageCode == 'ja'
                              ? TextStyle(
                                  fontSize: 30.sp,
                                  fontFamily: 'PretendardJP',
                                  color: (kiosk?.buttonTextColor ?? '').toColor(fallback: Colors.white),
                                  letterSpacing: -0.34,
                                  height: 1.0,
                                  fontWeight: FontWeight.bold,
                                )
                              : isHwe
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

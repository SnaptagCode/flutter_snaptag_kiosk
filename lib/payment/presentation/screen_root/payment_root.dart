import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/home/presentation/notifier/home_back_photo_type_notifier.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/domain/failures/payment_failure.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_action.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_notifier.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_state.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/screen/payment_screen.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/screen/payment_screen_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PaymentRoot extends ConsumerStatefulWidget {
  const PaymentRoot({super.key});

  @override
  ConsumerState<PaymentRoot> createState() => _PaymentRootState();
}

class _PaymentRootState extends ConsumerState<PaymentRoot> {
  bool _isNetworkErrorHandled = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(paymentNotifierProvider.notifier);
    final paymentState = ref.watch(paymentNotifierProvider);
    final backPhotoSession = ref.watch(backPhotoSessionProvider);

    final screenState = PaymentScreenState(
      isLoading: paymentState is PaymentStateLoading,
      kiosk: ref.watch(kioskInfoServiceProvider),
      selection: ref.watch(backPhotoTypeNotifierProvider),
      backPhotoUrl: backPhotoSession.valueOrNull?.formattedBackPhotoCardUrl,
      isBackPhotoLoading: backPhotoSession.isLoading,
      backPhotoError: backPhotoSession.error,
    );

    ref.listen<NetworkState>(networkStatusNotifierProvider, (previous, next) async {
      if (_isNetworkErrorHandled) return;
      if (previous?.status == next.status) return;

      final isNetworkDown =
          next.status == NetworkStatus.disconnected || next.status == NetworkStatus.unstable;
      if (!isNetworkDown) return;
      if (ref.read(paymentNotifierProvider) is! PaymentStateLoading) return;

      _isNetworkErrorHandled = true;

      if (!mounted) return;
      if (context.loaderOverlay.visible) context.loaderOverlay.hide();

      await DialogHelper.showKioskDialog(
        context,
        title: LocaleKeys.alert_title_network_error.tr(),
        contentText: LocaleKeys.alert_txt_print_network_error.tr(),
        confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
      );
      if (context.mounted) HomeRouteData().go(context);
    });

    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) async {
      switch (next) {
        case PaymentStateInitial():
          break;
        case PaymentStateLoading():
          if (mounted) context.loaderOverlay.show();
        case PaymentStateSuccess():
          if (mounted && context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (mounted) PrintProcessRouteData().go(context);
        case PaymentStateFailure(:final error):
          if (mounted && context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (_isNetworkErrorHandled) return;

          if (mounted) ref.read(homeTimeoutNotifierProvider.notifier).resumeTimer();

          SlackLogService().sendErrorLogToSlack('Payment process failed: $error');

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
      }
    });

    return PaymentScreen(
      state: screenState,
      onAction: (action) {
        switch (action) {
          case PaymentActionSelectFixed(:final index):
            ref.read(backPhotoTypeNotifierProvider.notifier).selectFixed(index);
          case PaymentActionRefreshBackPhoto():
            ref.invalidate(backPhotoSessionProvider);
          default:
            notifier.onAction(action);
        }
      },
    );
  }
}

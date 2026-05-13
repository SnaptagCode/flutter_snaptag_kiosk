import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_failed_type.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/screens/payment_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/photo_card_preview_screen_provider.dart';
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
    ref.listen<NetworkState>(networkStatusNotifierProvider, (previous, next) async {
      if (_isNetworkErrorHandled) return;
      if (previous?.status == next.status) return;

      final isNetworkDown =
          next.status == NetworkStatus.disconnected || next.status == NetworkStatus.unstable;
      if (!isNetworkDown) return;
      if (!ref.read(photoCardPreviewScreenProviderProvider).isLoading) return;

      _isNetworkErrorHandled = true;

      if (!mounted) return;
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      await DialogHelper.showKioskDialog(
        context,
        title: LocaleKeys.alert_title_network_error.tr(),
        contentText: LocaleKeys.alert_txt_print_network_error.tr(),
        confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
      );
      if (context.mounted) HomeRouteData().go(context);
    });

    ref.listen<AsyncValue<void>>(
      photoCardPreviewScreenProviderProvider,
      (previous, next) async {
        final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);

        if (next.isLoading) {
          if (mounted) context.loaderOverlay.show();
          return;
        }

        if (mounted && context.loaderOverlay.visible) {
          context.loaderOverlay.hide();
        }

        await next.when(
          error: (error, stack) async {
            if (_isNetworkErrorHandled) return;

            if (mounted) timeoutNotifier.resumeTimer();

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
          },
          loading: () => null,
          data: (_) async {
            PrintProcessRouteData().go(context);
          },
        );
      },
    );

    return const PaymentScreen();
  }
}

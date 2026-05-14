import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/verification_failure.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_service.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/auth_code_notifier.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/verification_action.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/verification_notifier.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/verification_state.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/screen/verification_screen.dart';
import 'package:loader_overlay/loader_overlay.dart';

class VerificationRoot extends ConsumerWidget {
  const VerificationRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<VerificationState>(verificationNotifierProvider, (_, state) async {
      switch (state) {
        case VerificationStateLoading():
          context.loaderOverlay.show();
        case VerificationStateSuccess():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          ref.read(authCodeProvider.notifier).clear();
          PhotoCardPreviewRouteData().go(context);
        case VerificationStateFailure(:final failure):
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          ref.read(authCodeProvider.notifier).clear();
          await _handleFailure(context, ref, failure);
        case VerificationStateInitial():
          break;
      }
    });

    return VerificationScreen(
      onAction: (action) => _handleAction(context, ref, action),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, VerificationAction action) {
    ref.read(verificationNotifierProvider.notifier).onAction(action);
  }

  Future<void> _handleFailure(
    BuildContext context,
    WidgetRef ref,
    VerificationFailure failure,
  ) async {
    switch (failure) {
      case VerificationFailureRefundRequired(:final order):
        final confirmed = await DialogHelper.showKioskDialog(
          context,
          title: LocaleKeys.alert_title_refund_info.tr(),
          contentText: LocaleKeys.alert_txt_refund_info.tr(),
          cancelButtonText: LocaleKeys.alert_btn_cancel.tr(),
          confirmButtonText: LocaleKeys.alert_btn_ok.tr(),
          confirmButtonStyle: context.dialogButtonStyle,
        );
        if (!context.mounted) return;
        if (confirmed && order != null) {
          try {
            final success = await ref.read(paymentServiceProvider.notifier).error409_refund(order);
            if (!context.mounted) return;
            await (success
                ? DialogHelper.showAuthNumReissueCompleteDialog(context)
                : DialogHelper.showAuthNumReissueFailureDialog(context));
          } catch (_) {
            if (context.mounted) await DialogHelper.showAuthNumReissueFailureDialog(context);
          }
        }
      case VerificationFailureInvalidCode():
        await DialogHelper.showErrorDialog(context);
      case VerificationFailureExpired():
        await DialogHelper.showVerificationCodeExpriedDialog(context);
      case VerificationFailureNetwork():
      case VerificationFailureUnknown():
        await DialogHelper.showErrorDialog(context);
        SlackLogService().sendLogToSlack('Verification error: ${failure.message}');
        logger.e('Verification error: ${failure.message}');
    }
  }
}

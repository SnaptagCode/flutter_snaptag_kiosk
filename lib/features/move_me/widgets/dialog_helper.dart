import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:go_router/go_router.dart';

class DialogHelper {
  static Future<bool> _showKioskDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onButtonPressed,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Center(
            child: Text(
              title,
              style: context.typography.kioskAlert1B,
            ),
          ),
          content: Text(
            message,
            style: context.typography.kioskAlert2M,
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      if (onButtonPressed != null) {
                        onButtonPressed();
                      }
                    },
                    style: context.dialogButtonStyle,
                    child: Text(
                      buttonText,
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
    return true;
  }

  //showCustomDialog
  static Future<void> showCustomDialog(BuildContext context,
      {required String title,
      required String message,
      required String buttonText,
      VoidCallback? onButtonPressed}) async {
    await _showKioskDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  static Future<void> showPrintCompleteDialog(BuildContext context) async {
    await _showKioskDialog(
      context,
      title: LocaleKeys.alert_title_print_complete.tr(),
      message: LocaleKeys.alert_txt_print_complete.tr(),
      buttonText: LocaleKeys.alert_btn_print_complete.tr(),
    );
  }

  static Future<void> showErrorDialog(BuildContext context) async {
    await _showKioskDialog(
      context,
      title: LocaleKeys.alert_title_authNum_error.tr(),
      message: LocaleKeys.alert_txt_authNum_error.tr(),
      buttonText: LocaleKeys.alert_btn_authNum_error.tr(),
    );
  }

  static Future<void> showPurchaseFailedDialog(BuildContext context, {Exception? exception}) async {
    await _showKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      message: '${LocaleKeys.alert_txt_purchase_failure.tr()}\n\n${exception.toString()}',
      buttonText: LocaleKeys.alert_btn_purchase_failure.tr(),
    );
  }

  static Future<bool> showPrintErrorDialog(BuildContext context) async {
    return await _showKioskDialog(
      context,
      title: LocaleKeys.alert_title_print_failure.tr(),
      message: LocaleKeys.alert_txt_print_failure.tr(),
      buttonText: LocaleKeys.alert_btn_print_failure.tr(),
    );
  }
}

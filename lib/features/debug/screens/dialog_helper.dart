import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/theme/button_styles.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:go_router/go_router.dart';

class DialogHelper {
  static Future<bool> _showKioskDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonText,
    required Color buttonColor,
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
            ),
          ),
          content: Text(
            message,
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

  static Future<void> showErrorDialog(BuildContext context) async {
    await _showKioskDialog(
      context,
      title: 'alert_title_authNum_error'.tr(),
      message: 'alert_txt_authNum_error'.tr(),
      buttonText: 'alert_btn_authNum_error'.tr(),
      buttonColor: context.kioskColors.popupButtonColor,
    );
  }

  static Future<void> showPurchaseFailedDialog(BuildContext context) async {
    await _showKioskDialog(
      context,
      title: 'alert_title_purchase_failure'.tr(),
      message: '${'alert_txt_purchase_failure'.tr()}\nError Code : 404, Unknown',
      buttonText: 'alert_btn_purchase_failure'.tr(),
      buttonColor: context.kioskColors.popupButtonColor,
    );
  }

  static Future<bool> showPrintErrorDialog(BuildContext context) async {
    return await _showKioskDialog(
      context,
      title: 'alert_title_failure_print'.tr(),
      message: 'alert_txt_failure_print'.tr(),
      buttonText: 'alert_btn_failure_print'.tr(),
      buttonColor: context.kioskColors.popupButtonColor,
    );
  }
}

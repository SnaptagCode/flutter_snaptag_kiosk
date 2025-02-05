import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/providers/sound_provider.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

///
/// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=943-15366&m=dev)
/// 고정 값
/// - `backgroundColor` : #FFFFFF
/// - `title` : #000000
/// - `message` : #000000
///
class DialogHelper {
  static Future<bool> showRefundFailDialog(
    BuildContext context,
  ) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                SnaptagSvg.error,
                width: 44.w,
                height: 44.w,
              ),
              SizedBox(width: 20.w),
              Text(
                '환불이 실패했습니다.',
                style: context.typography.kioskAlert1B.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<bool> showRefundSuccessDialog(
    BuildContext context,
  ) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                SnaptagSvg.success,
                width: 44.w,
                height: 44.4,
              ),
              SizedBox(width: 20.w),
              Text(
                '환불이 완료되었습니다.',
                style: context.typography.kioskAlert1B.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<bool> showSetupDialog(
    BuildContext context, {
    required String title,
    String cancelButtonText = '취소',
    String confirmButtonText = '확인',
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Center(
            child: Text(
              title,
              style: context.typography.kioskAlert1B.copyWith(
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      playSound();
                      Navigator.of(context).pop(false);
                    },
                    style: context.setupDialogCancelButtonStyle,
                    child: Text(
                      cancelButtonText,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      playSound();
                      Navigator.of(context).pop(true);
                    },
                    style: context.setupDialogConfirmButtonStyle,
                    child: Text(
                      confirmButtonText,
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  static Future<bool> _showOneButtonKioskDialog(
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
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Center(
            child: Text(
              title,
              style: context.typography.kioskAlert1B.copyWith(
                color: Colors.black,
              ),
            ),
          ),
          content: Text(
            message,
            style: context.typography.kioskAlert2M.copyWith(
              color: Colors.black,
            ),
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
    await _showOneButtonKioskDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  static Future<void> showPrintCompleteDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_print_complete.tr(),
      message: LocaleKeys.alert_txt_print_complete.tr(),
      buttonText: LocaleKeys.alert_btn_print_complete.tr(),
    );
  }

  static Future<void> showErrorDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_authNum_error.tr(),
      message: LocaleKeys.alert_txt_authNum_error.tr(),
      buttonText: LocaleKeys.alert_btn_authNum_error.tr(),
    );
  }

  static Future<void> showPurchaseFailedDialog(BuildContext context,
      {Exception? exception}) async {
    final error = exception != null && F.appFlavor == Flavor.dev
        ? '\n\n${exception.toString()}'
        : null;
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      message: '${LocaleKeys.alert_txt_purchase_failure.tr()}$error',
      buttonText: LocaleKeys.alert_btn_purchase_failure.tr(),
    );
  }

  static Future<bool> showPrintErrorDialog(BuildContext context,
      {Exception? exception}) async {
    final error = exception != null && F.appFlavor == Flavor.dev
        ? '\n\n${exception.toString()}'
        : null;
    return await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_print_failure.tr(),
      message: '${LocaleKeys.alert_txt_print_failure.tr()}$error',
      buttonText: LocaleKeys.alert_btn_print_failure.tr(),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/utils/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/widgets/code_keypad.dart';

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
        return DefaultTextStyle(
            style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja'?
            'MPLUSRounded' : 'Cafe24Ssurround2',
        ),
        child: AlertDialog(
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
                  fontFamily: 'Pretendard',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),);
      },
    );
  }

  static Future<bool> showRefundSuccessDialog(
    BuildContext context,
  ) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DefaultTextStyle(
            style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja'?
            'MPLUSRounded' : 'Cafe24Ssurround2',
        ),
        child: AlertDialog(
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
                  fontFamily: 'Pretendard',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),);
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
        return DefaultTextStyle(
            style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja'?
            'MPLUSRounded' : 'Cafe24Ssurround2',
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Center(
            child: Text(
              title,
              style: context.typography.kioskAlert1B.copyWith(
                fontFamily: 'Pretendard',
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await SoundManager().playSound();
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
                    onPressed: () async {
                      await SoundManager().playSound();
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
        ),);
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DefaultTextStyle(
            style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja'?
            'MPLUSRounded' : 'Cafe24Ssurround2',
        ),
        child: AlertDialog(
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
                fontFamily: context.locale.languageCode == 'ja'?
                    'MPLUSRounded' : 'Cafe24Ssurround2',
              ),
            ),
          ),
          content: Text(
            message,
            style: context.typography.kioskAlert2M.copyWith(
              color: Colors.black,
              fontFamily: 'Pretendard',
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
        ),);
      },
    );
    return true;
  }

  static Future<bool> showSetupTwoDialog(
      BuildContext context, {
        required String title,
        required String contentText,
        String cancelButtonText = '취소',
        String confirmButtonText = '확인',
      }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DefaultTextStyle(
          style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja'
                ? 'MPLUSRounded'
                : 'Cafe24Ssurround2',
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 100.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: context.typography.kioskAlert1B.copyWith(
                  fontFamily: 'Pretendard',
                  color: Colors.black,
                ),
              ),
            ),
            content: Text(
              contentText,
              textAlign: TextAlign.center,
              style: context.typography.kioskAlert2M.copyWith(
                fontFamily: 'Pretendard',
                color: Color(0xFF414448),
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await SoundManager().playSound();
                        Navigator.of(context).pop(false);
                      },
                      style: context.setupDialogCancelButtonStyle,
                      child: Text(cancelButtonText),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await SoundManager().playSound();
                        Navigator.of(context).pop(true);
                      },
                      style: context.setupDialogConfirmButtonStyle,
                      child: Text(confirmButtonText),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
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

  //    2.3.0 이하 버전용
  static Future<void> showPrintCompleteDialog( //5초 후 자동으로 닫히고 QR 화면으로 이동
    BuildContext context, {
    VoidCallback? onButtonPressed,
  }) async {
    Future.delayed(const Duration(seconds: 5), () {

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        PhotoCardUploadRouteData().go(context);
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_print_complete.tr(),
      message: LocaleKeys.alert_txt_print_complete.tr(),
      buttonText: LocaleKeys.alert_btn_print_complete.tr(),
      onButtonPressed: onButtonPressed,
    );
  }

  // 2.3.0 카운트 버전
  /*
  static Future<void> showPrintCompleteDialog(
      BuildContext context, {
        VoidCallback? onButtonPressed,
      }) async {
    int countdown = 3;

    await showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 임의로 닫지 못하도록 설정
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {

            void startCountdown() {
              Future.delayed(const Duration(seconds: 1), () {
                if (countdown > 1) {
                  setState(() {
                    countdown--;
                  });
                  startCountdown(); // 재귀적으로 호출하여 1초마다 감소
                } else {
                  if (Navigator.of(dialogContext).canPop()) {
                    PhotoCardUploadRouteData().go(dialogContext);
                    Navigator.of(dialogContext).pop();
                  }
                }
              });
            }

            if (countdown == 3) startCountdown();

            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Center(
                child: Text(
                  LocaleKeys.alert_title_print_complete.tr(),
                  style: context.typography.kioskAlert1B.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.alert_txt_print_complete.tr(),
                    style: context.typography.kioskAlert2M.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/alert_bufferring_bw.png', // ✅ 배경 이미지 경로
                        width: 144.w, // 크기 조정
                        height: 144.h,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        '$countdown',
                        style: const TextStyle(
                          fontSize: 42, // 폰트 크기 키움
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // 글자 색상
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    LocaleKeys.alert_txt_print_complete_02.tr(),
                    style: context.typography.kioskBody2B.copyWith(
                    color: Color(0xFFADADAD),
                  ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          onButtonPressed?.call();
                        },
                        style: context.dialogButtonStyle,
                        child: Text(LocaleKeys.alert_btn_print_complete.tr()),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }
  */



  static Future<void> showErrorDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_authNum_error.tr(),
      message: LocaleKeys.alert_txt_authNum_error.tr(),
      buttonText: LocaleKeys.alert_btn_authNum_error.tr(),
    );
  }

  static Future<void> showPurchaseFailedDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      message: LocaleKeys.alert_txt_purchase_failure.tr(),
      buttonText: LocaleKeys.alert_btn_purchase_failure.tr(),
    );
  }

  static Future<bool> showPrintErrorDialog(
    BuildContext context, {
    VoidCallback? onButtonPressed,
  }) async {
    return await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_print_failure.tr(),
      message: LocaleKeys.alert_txt_print_failure.tr(),
      buttonText: LocaleKeys.alert_btn_print_failure.tr(),
      onButtonPressed: onButtonPressed,
    );
  }

  static Future<bool> showPrintCardRefillDialog(
      BuildContext context, {
        VoidCallback? onButtonPressed,
      }) async {
    return await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_card_refill.tr(),
      message: LocaleKeys.alert_txt_card_refill.tr(),
      buttonText: LocaleKeys.alert_btn_card_refill.tr(),
      onButtonPressed: onButtonPressed,
    );
  }

  static Future<String?> showKeypadDialog(
      BuildContext context, {
        required ModeType mode,
      }) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return DefaultTextStyle(
            style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja'?
            'MPLUSRounded' : 'Cafe24Ssurround2',
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          content: SizedBox(
            width: 418.w,
            height: 600.h,
            child: AuthCodeKeypad(
              mode: mode,
              onCompleted: (code) {
                print("입력된 코드: $code");
                Navigator.pop(context, code);
              },
            ),
          ),
        ),);
      },
    );
  }

/* Admin 패스워드 실패시 다이얼로그
  static Future<void> showAdminFailDialog(
      BuildContext context, {
        VoidCallback? onButtonPressed,
      }) async {
    await _showOneButtonKioskDialog(
      context,
      title: '비밀번호 오류',
      message: '비밀번호를 다시 입력해주세요',
      buttonText: LocaleKeys.alert_btn_print_complete.tr(),
      onButtonPressed: onButtonPressed,
    );
  }
 */
}

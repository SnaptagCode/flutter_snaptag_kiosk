import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/code_keypad.dart';

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
            fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
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
        return DefaultTextStyle(
          style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
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
          ),
        );
      },
    );
  }

  static Future<bool> showSetupOneButtonDialog(
    BuildContext context, {
    required String title,
    String confirmButtonText = '확인',
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DefaultTextStyle(
          style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            title: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60.h, bottom: 36.h, left: 40.w, right: 40.w),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.typography.kioskAlert1B.copyWith(
                    fontFamily: 'Pretendard',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(bottom: 40.h, left: 40.w, right: 40.w),
                child: Row(
                  children: [
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
                ),
              )
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
        return DefaultTextStyle(
          style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            title: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60.h, bottom: 36.h, left: 40.w, right: 40.w),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.typography.kioskAlert1B.copyWith(
                    fontFamily: 'Pretendard',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(bottom: 40.h, left: 40.w, right: 40.w),
                child: Row(
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
                ),
              )
            ],
          ),
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DefaultTextStyle(
          style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            title: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60.h, bottom: 20.h, left: 40.w, right: 40.w),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.typography.kioskAlert1B.copyWith(
                    fontFamily: 'Pretendard',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            content: message.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(left: 40.w, right: 40.w),
                    child: Text(
                      message,
                      style: context.typography.kioskAlert2M.copyWith(
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : null,
            actions: [
              Padding(
                padding: EdgeInsets.only(bottom: 40.h, top: 36.h, left: 40.w, right: 40.w),
                child: Row(
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
                ),
              )
            ],
          ),
        );
      },
    );
    return true;
  }

  static Future<bool> showTwoButtonKioskDialog(
    BuildContext context,
    ButtonStyle? confirmButtonStyle, {
    required String title,
    required String contentText,
    required String cancelButtonText,
    required String confirmButtonText,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DefaultTextStyle(
          style: TextStyle(
            fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
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
                      style: context.refundDialogCancelButtonStyle,
                      child: Text(cancelButtonText, style: TextStyle(color: Color(0xFF999999))),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await SoundManager().playSound();
                        Navigator.of(context).pop(true);
                      },
                      style: context.dialogKioskStyle,
                      child: Text(confirmButtonText, style: TextStyle(color: Color(0xFFFFFFFF))),
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
  static Future<void> showPrintCompleteDialog(
    //5초 후 자동으로 닫히고 QR 화면으로 이동
    BuildContext context, {
    VoidCallback? onButtonPressed,
  }) async {
    Future.delayed(const Duration(seconds: 5), () {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        HomeRouteData().go(context);
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

  /// 타임아웃 알럿 (실시간 카운트다운 표시)
  static Future<bool> showTimeoutDialog(
    BuildContext context,
    ButtonStyle? confirmButtonStyle, {
    required String title,
    required String cancelButtonText,
    required String confirmButtonText,
    required int countdownSeconds,
    required VoidCallback onAutoClose,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _TimeoutDialogWidget(
          title: title,
          cancelButtonText: cancelButtonText,
          confirmButtonText: confirmButtonText,
          confirmButtonStyle: confirmButtonStyle,
          countdownSeconds: countdownSeconds,
          onAutoClose: onAutoClose,
        );
      },
    );
  }

  static Future<void> showCardLimitExceededDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      message: "카드 한도가 초과되었습니다.",
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showInsufficientBalanceDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      message: "카드 잔액이 부족합니다.",
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showVerificationErrorDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      message: "카드 인증에 실패했습니다.",
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showMerchantRestrictionDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      message: "해당 가맹점에서 사용할 수 없습니다.",
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showTimeoutPaymentDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      message: "결제 시간이 초과되었습니다.",
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showPrintWaitingDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: "프린트가 준비중입니다.",
      message: "",
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showNeedRibbonFilmDialog(BuildContext context, VoidCallback? onButtonPressed) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_need_ribbon_film.tr(),
      message: LocaleKeys.alert_txt_need_ribbon_film.tr(),
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
      onButtonPressed: onButtonPressed,
    );
  }

  static Future<void> showAuthNumReissueCompleteDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_authNum_reissue_complete.tr(),
      message: LocaleKeys.alert_txt_authNum_reissue_complete.tr(),
      buttonText: LocaleKeys.alert_btn_authNum_reissue_complete.tr(),
    );
  }

  static Future<void> showEmptyEventDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_empty_event.tr(),
      message: "",
      buttonText: LocaleKeys.alert_btn_ok.tr(),
    );
  }

  static Future<void> showAuthNumReissueFailureDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_authNum_reissue_failure.tr(),
      message: LocaleKeys.alert_txt_authNum_reissue_failure.tr(),
      buttonText: LocaleKeys.alert_btn_authNum_reissue_failure.tr(),
    );
  }

  static Future<void> showCheckPrintStateDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: "프린트 기기 상태를 확인해주세요.",
      message: "",
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
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

  static Future<void> showVerificationCodeExpriedDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_verification_code_expried.tr(),
      message: LocaleKeys.alert_txt_verification_code_expried.tr(),
      buttonText: LocaleKeys.alert_btn_verification_code_expried.tr(),
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

  static Future<void> showPaymentCardFailedDialog(BuildContext context) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_paymentcard_failure.tr(),
      message: LocaleKeys.alert_txt_paymentcard_failure.tr(),
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showAutoRefundDescriptionDialog(
    BuildContext context, {
    VoidCallback? onButtonPressed,
  }) async {
    await _showOneButtonKioskDialog(
      context,
      title: LocaleKeys.alert_title_auto_refund_alert.tr(),
      message: LocaleKeys.alert_txt_auto_refund_alert.tr(),
      buttonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
      onButtonPressed: onButtonPressed,
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
            fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
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
          ),
        );
      },
    );
  }
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

/// 타임아웃 다이얼로그 위젯 (실시간 카운트다운)
class _TimeoutDialogWidget extends StatefulWidget {
  final String title;
  final String cancelButtonText;
  final String confirmButtonText;
  final ButtonStyle? confirmButtonStyle;
  final int countdownSeconds;
  final VoidCallback onAutoClose;

  const _TimeoutDialogWidget({
    required this.title,
    required this.cancelButtonText,
    required this.confirmButtonText,
    this.confirmButtonStyle,
    required this.countdownSeconds,
    required this.onAutoClose,
  });

  @override
  State<_TimeoutDialogWidget> createState() => _TimeoutDialogWidgetState();
}

class _TimeoutDialogWidgetState extends State<_TimeoutDialogWidget> {
  late int _remainingSeconds;
  Timer? _countdownTimer;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;

    // 1초마다 카운트다운 업데이트
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });

    // 자동으로 닫기
    _autoCloseTimer = Timer(Duration(seconds: widget.countdownSeconds), () {
      if (mounted) {
        widget.onAutoClose();
        Navigator.of(context, rootNavigator: true).pop(true);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // showTwoButtonKioskDialog와 동일한 구조 사용
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60.h, bottom: 20.h, left: 40.w, right: 40.w),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.typography.kioskAlert1B.copyWith(
                fontFamily: 'Pretendard',
                color: Colors.black,
              ),
            ),
          ),
        ),
        content: Text(
          '일정 시간 동안 사용이 없어\n$_remainingSeconds초 후 홈 화면으로 이동합니다',
          textAlign: TextAlign.center,
          style: context.typography.kioskAlert2M.copyWith(
            fontFamily: 'Pretendard',
            color: Color(0xFF414448),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(bottom: 40.h, top: 36.h, left: 40.w, right: 40.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await SoundManager().playSound();
                      Navigator.of(context).pop(false);
                    },
                    style: context.refundDialogCancelButtonStyle,
                    child: Text(widget.cancelButtonText, style: TextStyle(color: Color(0xFF999999))),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await SoundManager().playSound();
                      Navigator.of(context).pop(true);
                    },
                    style: widget.confirmButtonStyle ?? context.refundDialogConfirmButtonStyle,
                    child: Text(widget.confirmButtonText, style: TextStyle(color: Color(0xFFFFFFFF))),
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

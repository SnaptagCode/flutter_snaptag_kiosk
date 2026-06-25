import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/code_keypad.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          child: Center(
            child: SizedBox(
              width: 658.w,
              child: AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: EdgeInsets.zero,
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
            ),
          ),
        );
      },
    );
  }

  static Future<void> showRefundSuccessDialog(
    BuildContext context, {
    required int amount,
    Duration? autoCloseDuration,
  }) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_refund_complete.tr(),
      contentText: LocaleKeys.alert_txt_refund_complete.tr(namedArgs: {'amount': amount.toString()}),
      confirmButtonText: LocaleKeys.alert_btn_ok.tr(),
      autoCloseDuration: autoCloseDuration,
    );
  }

  static Future<void> showRefundFailedDialog(
    BuildContext context, {
    required String reason,
    Duration? autoCloseDuration,
  }) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_refund_failed.tr(),
      contentText: reason,
      confirmButtonText: LocaleKeys.alert_btn_ok.tr(),
      autoCloseDuration: autoCloseDuration,
    );
  }

  static Future<bool> showRefundCardInsertDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _RefundCardInsertDialogWidget(),
        ) ??
        false;
  }

  /// 공통 확인/취소 다이얼로그. [showSetupDialog], [showKioskDialog]에서 사용.
  static Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? subContent,
    bool showCancelButton = false,
    String cancelButtonText = '취소',
    required String confirmButtonText,
    required ButtonStyle cancelButtonStyle,
    required ButtonStyle confirmButtonStyle,
    TextStyle? cancelTextStyle,
    TextStyle? confirmTextStyle,
    bool barrierDismissible = false,
    Duration? autoCloseDuration,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        final isHwe = context.isHwe;

        return _AutoCloseScope(
          // 타이머를 다이얼로그 라이프사이클에 바인딩한다. 사용자가 먼저 닫으면
          // dispose에서 타이머가 취소되고, 발화 시에도 자기 다이얼로그만 pop한다.
          duration: autoCloseDuration,
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
            ),
            child: Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: 211.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60.h, left: 40.w, right: 40.w),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: context.typography.kioskAlert1B.copyWith(
                          fontFamily: isHwe ? 'Hanwha' : 'Pretendard',
                          color: Colors.black,
                          fontSize: isHwe ? 52.sp : 42.sp,
                        ),
                      ),
                    ),
                  ),
                  if (content != null)
                    Padding(
                      padding: EdgeInsets.only(top: 20.h, left: 40.w, right: 40.w),
                      child: Text(
                        content,
                        textAlign: TextAlign.center,
                        style: context.typography.kioskAlert2M.copyWith(
                          color: Colors.black,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  if (subContent != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h, left: 40.w, right: 40.w),
                      child: Text(
                        subContent,
                        textAlign: TextAlign.center,
                        style: context.typography.kioskAlert2M.copyWith(
                          color: const Color(0xFFFF333F),
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 36.h, bottom: 40.h, left: 40.w, right: 40.w),
                    child: Row(
                      children: [
                        if (showCancelButton)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await SoundManager().playSound();
                                Navigator.of(dialogContext).pop(false);
                              },
                              style: cancelButtonStyle,
                              child: Text(cancelButtonText, style: cancelTextStyle),
                            ),
                          ),
                        if (showCancelButton) SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await SoundManager().playSound();
                              Navigator.of(dialogContext).pop(true);
                            },
                            style: confirmButtonStyle,
                            child: Text(confirmButtonText, style: confirmTextStyle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  static Future<bool> showSetupDialog(
    BuildContext context, {
    required String title,
    String? content,
    bool showCancelButton = false,
    String cancelButtonText = '취소',
    String confirmButtonText = '확인',
  }) async {
    return await _showConfirmDialog(
      context,
      title: title,
      content: content,
      showCancelButton: showCancelButton,
      cancelButtonText: cancelButtonText,
      confirmButtonText: confirmButtonText,
      cancelButtonStyle: context.setupDialogCancelButtonStyle,
      confirmButtonStyle: context.setupDialogConfirmButtonStyle,
    );
  }

  static Future<bool> showKioskDialog(
    BuildContext context, {
    required String title,
    required String contentText,
    String? subContentText,
    String? cancelButtonText,
    required String confirmButtonText,
    ButtonStyle? confirmButtonStyle,
    bool barrierDismissible = false,
    Duration? autoCloseDuration,
  }) async {
    return await _showConfirmDialog(
      context,
      title: title,
      content: contentText,
      subContent: subContentText,
      showCancelButton: cancelButtonText != null,
      cancelButtonText: cancelButtonText ?? '취소',
      confirmButtonText: confirmButtonText,
      cancelButtonStyle: context.refundDialogCancelButtonStyle,
      confirmButtonStyle: confirmButtonStyle ?? context.dialogKioskStyle,
      cancelTextStyle: TextStyle(color: const Color(0xFF999999)),
      confirmTextStyle: TextStyle(color: const Color(0xFFFFFFFF)),
      barrierDismissible: barrierDismissible,
      autoCloseDuration: autoCloseDuration,
    );
  }

  static Future<void> showPrintCompleteDialog(
    //5초 후 자동으로 닫히고 QR 화면으로 이동
    BuildContext context, {
    VoidCallback? onButtonPressed,
  }) async {
    Future.delayed(const Duration(seconds: 5), () {
      if (!context.mounted) return;
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        HomeRouteData().go(context);
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
    final result = await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_print_complete.tr(),
      contentText: LocaleKeys.alert_txt_print_complete.tr(),
      confirmButtonText: LocaleKeys.alert_btn_print_complete.tr(),
    );

    if (result) {
      HomeRouteData().go(context);
    }
  }

  /// 타임아웃 알럿 (실시간 카운트다운 표시)
  static Future<bool> showTimeoutDialog(
    BuildContext context,
    ButtonStyle? confirmButtonStyle, {
    required String title,
    String? message,
    String? messageKey,
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
          message: message,
          messageKey: messageKey,
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
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      contentText: LocaleKeys.alert_txt_card_limit_exceeded.tr(),
      confirmButtonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showInsufficientBalanceDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      contentText: LocaleKeys.alert_txt_insufficient_balance.tr(),
      confirmButtonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showVerificationErrorDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      contentText: LocaleKeys.alert_txt_verification_error.tr(),
      confirmButtonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showMerchantRestrictionDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      contentText: LocaleKeys.alert_txt_merchant_restriction.tr(),
      confirmButtonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showTimeoutPaymentDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      contentText: LocaleKeys.alert_txt_timeout_payment.tr(),
      confirmButtonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
    );
  }

  static Future<void> showAuthNumReissueCompleteDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_authNum_reissue_complete.tr(),
      contentText: LocaleKeys.alert_txt_authNum_reissue_complete.tr(),
      confirmButtonText: LocaleKeys.alert_btn_authNum_reissue_complete.tr(),
    );
  }

  static Future<void> showAuthNumReissueFailureDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_authNum_reissue_failure.tr(),
      contentText: LocaleKeys.alert_txt_authNum_reissue_failure.tr(),
      confirmButtonText: LocaleKeys.alert_btn_authNum_reissue_failure.tr(),
    );
  }

  static Future<void> showErrorDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_authNum_error.tr(),
      contentText: LocaleKeys.alert_txt_authNum_error.tr(),
      confirmButtonText: LocaleKeys.alert_btn_authNum_error.tr(),
    );
  }

  static Future<void> showVerificationCodeExpriedDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_verification_code_expried.tr(),
      contentText: LocaleKeys.alert_txt_verification_code_expried.tr(),
      confirmButtonText: LocaleKeys.alert_btn_verification_code_expried.tr(),
    );
  }

  static Future<void> showPurchaseFailedDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_purchase_failure.tr(),
      contentText: LocaleKeys.alert_txt_purchase_failure.tr(),
      confirmButtonText: LocaleKeys.alert_btn_purchase_failure.tr(),
    );
  }

  static Future<void> showPaymentPreparationFailedDialog(BuildContext context) async {
    await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_payment_prep_failure.tr(),
      contentText: LocaleKeys.alert_txt_payment_prep_failure.tr(),
      confirmButtonText: LocaleKeys.alert_btn_payment_prep_failure.tr(),
    );
  }

  static Future<bool> showPrintErrorDialog(BuildContext context) async {
    return await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_print_failure.tr(),
      contentText: LocaleKeys.alert_txt_print_failure.tr(),
      confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
    );
  }

  static Future<bool> showPrintCardRefillDialog(BuildContext context) async {
    return await showKioskDialog(
      context,
      title: LocaleKeys.alert_title_card_refill.tr(),
      contentText: LocaleKeys.alert_txt_card_refill.tr(),
      confirmButtonText: LocaleKeys.alert_btn_card_refill.tr(),
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

/// 다이얼로그 자동 닫힘 스코프.
/// [duration]이 지정되면 그 시간 후 자기 다이얼로그를 닫는다([maybePop]).
/// 타이머가 위젯 라이프사이클에 묶여 있어, 사용자가 먼저 닫으면 [dispose]에서
/// 타이머가 취소되고 스테일 발화로 다른 라우트를 잘못 pop하지 않는다.
class _AutoCloseScope extends StatefulWidget {
  final Duration? duration;
  final Widget child;

  const _AutoCloseScope({required this.duration, required this.child});

  @override
  State<_AutoCloseScope> createState() => _AutoCloseScopeState();
}

class _AutoCloseScopeState extends State<_AutoCloseScope> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration;
    if (duration != null) {
      _timer = Timer(duration, () {
        if (!mounted) return;
        Navigator.of(context).maybePop(false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 타임아웃 다이얼로그 위젯 (실시간 카운트다운)
class _TimeoutDialogWidget extends StatefulWidget {
  final String title;
  final String? message;
  final String? messageKey;
  final String cancelButtonText;
  final String confirmButtonText;
  final ButtonStyle? confirmButtonStyle;
  final int countdownSeconds;
  final VoidCallback onAutoClose;

  const _TimeoutDialogWidget({
    required this.title,
    this.message,
    this.messageKey,
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
      if (!mounted) return;

      final navigator = Navigator.of(context, rootNavigator: true);

      widget.onAutoClose();
      navigator.pop(true);
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
      child: Center(
        child: SizedBox(
          width: 658.w,
          child: AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.zero,
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
            content: Padding(
              padding: EdgeInsets.only(left: 40.w, right: 40.w),
              child: Text(
                widget.messageKey != null
                    ? widget.messageKey!.tr().replaceAll('{}', '$_remainingSeconds')
                    : (widget.message?.replaceAll('{}', '$_remainingSeconds') ?? ''),
                textAlign: TextAlign.center,
                style: context.typography.kioskAlert2M.copyWith(
                  fontFamily: 'Pretendard',
                  color: Color(0xFF414448),
                ),
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
        ),
      ),
    );
  }
}

/// 환불 진행 안내 다이얼로그 (30초 카운트다운, 타임아웃 시 자동 취소)
class _RefundCardInsertDialogWidget extends StatefulWidget {
  const _RefundCardInsertDialogWidget();

  @override
  State<_RefundCardInsertDialogWidget> createState() => _RefundCardInsertDialogWidgetState();
}

class _RefundCardInsertDialogWidgetState extends State<_RefundCardInsertDialogWidget> {
  static const int _totalSeconds = 30;
  late int _remainingSeconds;
  Timer? _countdownTimer;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _totalSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remainingSeconds = (_remainingSeconds - 1).clamp(0, _totalSeconds));
    });
    _autoCloseTimer = Timer(const Duration(seconds: _totalSeconds), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(false);
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
    final isHwe = context.isHwe;
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 211.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60.h, left: 40.w, right: 40.w),
                child: Text(
                  LocaleKeys.alert_title_refund_card_insert.tr(),
                  textAlign: TextAlign.center,
                  style: context.typography.kioskAlert1B.copyWith(
                    fontFamily: isHwe ? 'Hanwha' : 'Pretendard',
                    color: Colors.black,
                    fontSize: isHwe ? 52.sp : 42.sp,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.h, left: 40.w, right: 40.w),
              child: Text(
                LocaleKeys.alert_txt_refund_card_insert.tr(namedArgs: {'seconds': _remainingSeconds.toString()}),
                textAlign: TextAlign.center,
                style: context.typography.kioskAlert2M.copyWith(
                  color: Colors.black,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 36.h, bottom: 40.h, left: 40.w, right: 40.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await SoundManager().playSound();
                        if (mounted) Navigator.of(context, rootNavigator: true).pop(false);
                      },
                      style: context.refundDialogCancelButtonStyle,
                      child: Text(LocaleKeys.alert_btn_cancel.tr(), style: const TextStyle(color: Color(0xFF999999))),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await SoundManager().playSound();
                        if (mounted) Navigator.of(context, rootNavigator: true).pop(true);
                      },
                      style: context.dialogKioskStyle,
                      child: Text(LocaleKeys.alert_btn_ok.tr(), style: const TextStyle(color: Color(0xFFFFFFFF))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

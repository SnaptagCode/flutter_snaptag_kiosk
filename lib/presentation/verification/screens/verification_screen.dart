import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/auth_code_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/notifiers/verification_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/notifiers/verification_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/notifiers/verification_state.dart';

class VerificationScreen extends ConsumerWidget {
  final void Function(VerificationAction) onAction;

  const VerificationScreen({super.key, required this.onAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHwe = ref.watch(kioskInfoServiceProvider)?.isHwe ?? false;
    final mainTextColor =
        ref.watch(kioskInfoServiceProvider)?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.choice_enter_verification_code.tr(),
            style: isHwe
                ? context.typography.vendingTitle1B.copyWith(color: Colors.white)
                : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
          ),
          SizedBox(height: 70.h),
          Text(
            LocaleKeys.sub01_txt_01.tr(),
            style: isHwe
                ? context.typography.vendingBody1B.copyWith(color: mainTextColor, fontSize: 36.sp)
                : context.typography.kioskBody1B,
          ),
          ...[LocaleKeys.sub01_txt_02.tr().isNotEmpty ? SizedBox(height: 12.h) : SizedBox(height: 0)],
          Text(
            LocaleKeys.sub01_txt_02.tr(),
            style: context.typography.kioskBody1B,
          ).validate(),
          SizedBox(height: 40.h),
          SizedBox(
            width: 418.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _InputDisplay(onClear: onAction),
                SizedBox(height: 30.h),
                _NumericPad(onAction: onAction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputDisplay extends ConsumerWidget {
  final void Function(VerificationAction) onClear;

  const _InputDisplay({required this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keypadState = ref.watch(authCodeProvider);
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Container(
        width: 478.w,
        height: 86.h,
        decoration: context.keypadDisplayDecoration,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    keypadState,
                    textAlign: TextAlign.center,
                    style: context.typography.kioskInput1B.copyWith(color: Colors.black),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => ref.read(authCodeProvider.notifier).clear(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Image.asset(
                    SnaptagImages.close,
                    width: 38.w,
                    height: 38.h,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumericPad extends ConsumerWidget {
  final void Function(VerificationAction) onAction;

  const _NumericPad({required this.onAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      verificationNotifierProvider.select((s) => s is VerificationStateLoading),
    );

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int row = 0; row < 4; row++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 0; col < 3; col++) ...[
                  _buildGridItem(context, ref, row * 3 + col, isLoading),
                  if (col < 2) SizedBox(width: 10.w),
                ],
              ],
            ),
            if (row < 3) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, WidgetRef ref, int index, bool isLoading) {
    if (index == 9) {
      return ElevatedButton(
        style: context.keypadNumberStyle,
        onPressed: isLoading
            ? null
            : () async {
                await SoundManager().playSound();
                ref.read(authCodeProvider.notifier).removeLast();
              },
        child: SizedBox(
          width: 60.w,
          height: 60.h,
          child: Image.asset(
            SnaptagImages.arrowBack,
            color: context.kioskColors.keypadTextColor,
          ),
        ),
      );
    }
    if (index == 10) {
      return ElevatedButton(
        style: context.keypadNumberStyle,
        onPressed: isLoading
            ? null
            : () async {
                await SoundManager().playSound();
                ref.read(authCodeProvider.notifier).addNumber('0');
              },
        child: const Text('0'),
      );
    }
    if (index == 11) {
      return ElevatedButton(
        style: context.keypadCompleteStyle,
        onPressed: isLoading
            ? null
            : () async {
                await SoundManager().playSound();
                final code = ref.read(authCodeProvider);
                if (ref.read(authCodeProvider.notifier).isValid()) {
                  onAction(VerificationActionSubmit(code));
                }
              },
        child: Text(LocaleKeys.sub01_btn_done.tr()),
      );
    }
    return ElevatedButton(
      style: context.keypadNumberStyle,
      onPressed: isLoading
          ? null
          : () async {
              await SoundManager().playSound();
              ref.read(authCodeProvider.notifier).addNumber('${index + 1}');
            },
      child: Text('${index + 1}'),
    );
  }
}

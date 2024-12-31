import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/theme/button_styles.dart';
import 'package:flutter_snaptag_kiosk/features/debug/screens/dialog_helper.dart';

class KioskComponentsScreen extends ConsumerWidget {
  const KioskComponentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Button Styles'),
            ElevatedButton(
              onPressed: () {},
              style: context.mainLargeButtonStyle,
              child: Text('main_btn_txt'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: context.dialogButtonStyle,
              child: Text('alert_btn_authNum_error'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: context.paymentButtonStyle,
              child: Text('sub02_btn_pay'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: context.keypadNumberStyle,
              child: const Text('1'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: context.keypadCompleteStyle,
              child: Text('sub01_btn_done'.tr()),
            ),
            const Text('Dialog Test'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => DialogHelper.showErrorDialog(context),
              style: context.dialogButtonStyle,
              child: Text('Show Error Dialog'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => DialogHelper.showPurchaseFailedDialog(context),
              style: context.dialogButtonStyle,
              child: Text('Show Purchase Failed Dialog'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => DialogHelper.showPrintErrorDialog(context),
              style: context.dialogButtonStyle,
              child: Text('Show Print Error Dialog'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

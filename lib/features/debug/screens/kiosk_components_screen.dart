import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class KioskComponentsScreen extends ConsumerWidget {
  const KioskComponentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localization Test'),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (Locale locale) {
              context.setLocale(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('ko', 'KR'),
                child: Text('Korean'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('ja', 'JP'),
                child: Text('Japanese'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('en', 'US'),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('zh', 'CN'),
                child: Text('Chinese'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Button Styles'),
            ElevatedButton(
              onPressed: () {},
              style: context.mainLargeButtonStyle,
              child: Text(LocaleKeys.main_btn_txt.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: context.dialogButtonStyle,
              child: Text(LocaleKeys.alert_btn_authNum_error.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: context.paymentButtonStyle,
              child: Text(LocaleKeys.sub02_btn_pay.tr()),
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
              child: Text(LocaleKeys.sub01_btn_done.tr()),
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
            const SizedBox(height: 16),
            const Text('Localization Texts'),
            const SizedBox(height: 16),
            Text(LocaleKeys.main_txt_01_01.tr()).validate(),
            Text(LocaleKeys.main_txt_01_02.tr()).validate(),
            Text(LocaleKeys.main_txt_01_03.tr()).validate(),
            Text(LocaleKeys.main_txt_02.tr()).validate(),
            Text(LocaleKeys.main_btn_txt.tr()).validate(),
            Text(LocaleKeys.sub01_txt_01.tr()).validate(),
            Text(LocaleKeys.sub01_btn_done.tr()).validate(),
            Text(LocaleKeys.alert_title_authNum_error.tr()).validate(),
            Text(LocaleKeys.alert_txt_authNum_error.tr()).validate(),
            Text(LocaleKeys.alert_btn_authNum_error.tr()).validate(),
            Text(LocaleKeys.sub02_txt_01.tr()).validate(),
            Text(LocaleKeys.sub02_btn_pay.tr()).validate(),
            Text(LocaleKeys.sub03_txt_01.tr()).validate(),
            Text(LocaleKeys.sub03_txt_02.tr()).validate(),
            Text(LocaleKeys.alert_title_print_complete.tr()).validate(),
            Text(LocaleKeys.alert_txt_print_complete.tr()).validate(),
            Text(LocaleKeys.alert_btn_print_complete.tr()).validate(),
            Text(LocaleKeys.alert_title_purchase_failure.tr()).validate(),
            Text(LocaleKeys.alert_txt_purchase_failure.tr()).validate(),
            Text(LocaleKeys.alert_btn_purchase_failure.tr()).validate(),
            Text(LocaleKeys.alert_title_print_failure.tr()).validate(),
            Text(LocaleKeys.alert_txt_print_failure.tr()).validate(),
            Text(LocaleKeys.alert_btn_print_failure.tr()).validate(),
          ],
        ),
      ),
    );
  }
}

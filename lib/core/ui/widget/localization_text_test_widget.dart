import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/language_switcher.dart';

class LocalizationTextTestWidget extends StatelessWidget {
  const LocalizationTextTestWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LanguageSwitcher(),
          ],
        ),
        _buildLocalizedCard(LocaleKeys.main_txt_01_01),
        _buildLocalizedCard(LocaleKeys.main_txt_01_02),
        _buildLocalizedCard(LocaleKeys.main_txt_01_03),
        _buildLocalizedCard(LocaleKeys.main_txt_02),
        _buildLocalizedCard(LocaleKeys.main_btn_txt),
        _buildLocalizedCard(LocaleKeys.sub01_txt_01),
        _buildLocalizedCard(LocaleKeys.sub01_btn_done),
        _buildLocalizedCard(LocaleKeys.alert_title_authNum_error),
        _buildLocalizedCard(LocaleKeys.alert_txt_authNum_error),
        _buildLocalizedCard(LocaleKeys.alert_btn_authNum_error),
        _buildLocalizedCard(LocaleKeys.sub02_txt_01),
        _buildLocalizedCard(LocaleKeys.sub02_btn_pay),
        _buildLocalizedCard(LocaleKeys.sub03_txt_01),
        _buildLocalizedCard(LocaleKeys.sub03_txt_02),
        _buildLocalizedCard(LocaleKeys.alert_title_print_complete),
        _buildLocalizedCard(LocaleKeys.alert_txt_print_complete),
        _buildLocalizedCard(LocaleKeys.alert_txt_print_complete_02),
        _buildLocalizedCard(LocaleKeys.alert_btn_print_complete),
        _buildLocalizedCard(LocaleKeys.alert_title_purchase_failure),
        _buildLocalizedCard(LocaleKeys.alert_txt_purchase_failure),
        _buildLocalizedCard(LocaleKeys.alert_btn_purchase_failure),
        _buildLocalizedCard(LocaleKeys.alert_title_print_failure),
        _buildLocalizedCard(LocaleKeys.alert_txt_print_failure),
        _buildLocalizedCard(LocaleKeys.alert_btn_print_failure),
      ],
    );
  }

  Widget _buildLocalizedCard(String localeKey) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(localeKey.tr()).validate(),
      ),
    );
  }
}

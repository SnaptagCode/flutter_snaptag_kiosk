import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';

class KioskTypographyWidget extends StatelessWidget {
  const KioskTypographyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final kioskTypography = context.theme.extension<KioskTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypographyDisplay('Kiosk Button 1 (Bold)', kioskTypography.kioskBtn1B),
        _TypographyDisplay('Kiosk Body 1 (Semi Bold)', kioskTypography.kioskBody1B),
        _TypographyDisplay('Kiosk Body 2 (Semi Bold)', kioskTypography.kioskBody2B),
        _TypographyDisplay('Kiosk Number 1 (Semi Bold)', kioskTypography.kioksNum1SB),
        _TypographyDisplay('Kiosk Number 2 (Bold)', kioskTypography.kioskNum2B),
        _TypographyDisplay('Kiosk Alert 1 (Bold)', kioskTypography.kioskAlert1B),
        _TypographyDisplay('Kiosk Alert 2 (Medium)', kioskTypography.kioskAlert2M),
        _TypographyDisplay('Kiosk Alert Button (Bold)', kioskTypography.kioskAlertBtnB),
        _TypographyDisplay('Kiosk Input 1 (Bold)', kioskTypography.kioskInput1B),
        _TypographyDisplay('Kiosk Input 2 (Bold)', kioskTypography.kioskInput2B),
        _TypographyDisplay('Kiosk Input 3 (Bold)', kioskTypography.kioskInput3B),
      ],
    );
  }
}

class _TypographyDisplay extends StatelessWidget {
  const _TypographyDisplay(this.name, this.style);

  final String name;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ColoredBox(
                color: context.theme.colorScheme.primary.withOpacity(0.3),
                child: Text.rich(
                  TextSpan(
                    text: '$name : ',
                    children: <TextSpan>[
                      TextSpan(
                        text: 'sub01_btn_done'.tr(),
                      ),
                    ],
                  ),
                  style: style,
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Size: ${style.fontSize?.toStringAsFixed(1)}sp, '
                      'Weight: ${style.fontWeight}, '
                      'Height: ${style.height?.toStringAsFixed(1)}, '
                      'Letter Spacing: ${style.letterSpacing?.toStringAsFixed(2)}',
                  style: context.theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_test_widget.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/flavor_info_widget.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/kiosk_colors_widget.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/kiosk_typography_screen.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/localization_text_test_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KioskComponentsScreen extends ConsumerWidget {
  const KioskComponentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.only(left: 30.w),
          icon: SvgPicture.asset(SnaptagSvg.arrowBack),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            KioskColorsWidget(),
            KioskTypographyWidget(),
            const FlavorInfoWidget(),
            const SizedBox(height: 16),
            Text('Dialogs', style: Theme.of(context).textTheme.headlineSmall),
            DialogTestWidget(),
            const SizedBox(height: 16),
            Text('Localization', style: Theme.of(context).textTheme.headlineSmall),
            LocalizationTextTestWidget(),
          ],
        ),
      ),
    );
  }
}

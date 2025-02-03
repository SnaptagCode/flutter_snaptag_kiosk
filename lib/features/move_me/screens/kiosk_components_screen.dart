import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class KioskComponentsScreen extends ConsumerWidget {
  const KioskComponentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
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

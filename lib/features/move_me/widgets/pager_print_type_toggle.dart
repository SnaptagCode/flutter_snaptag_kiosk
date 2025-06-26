import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class PagerPrintTypeToggle extends ConsumerWidget {
  const PagerPrintTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDouble = ref.watch(pagePrintProvider) == PagePrintType.double;

    return ToggleButtons(
      isSelected: [isDouble, !isDouble],
      onPressed: (_) => ref.read(pagePrintProvider.notifier).switchType(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("양면"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("단면"),
        ),
      ],
    );
  }
}

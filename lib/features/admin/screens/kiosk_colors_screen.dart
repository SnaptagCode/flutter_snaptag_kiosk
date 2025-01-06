import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class KioskColorsScreen extends ConsumerWidget {
  const KioskColorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kioskColors = context.theme.extension<KioskColors>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorGroup('Button Colors', [
            _ColorDisplay('Button Color', kioskColors.buttonColor),
            _ColorDisplay('Button Text Color', kioskColors.buttonTextColor),
          ]),
          const SizedBox(height: 24),
          _buildColorGroup('Keypad Colors', [
            _ColorDisplay('Keypad Button Color', kioskColors.keypadButtonColor),
          ]),
          const SizedBox(height: 24),
          _buildColorGroup('Text Colors', [
            _ColorDisplay('Text Color', kioskColors.textColor),
            _ColorDisplay('Coupon Text Color', kioskColors.couponTextColor),
          ]),
          const SizedBox(height: 24),
          _buildColorGroup('Others', [
            _ColorDisplay('Popup Button Color', kioskColors.popupButtonColor),
          ]),
        ],
      ),
    );
  }

  Widget _buildColorGroup(String title, List<Widget> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors,
        ),
      ],
    );
  }
}

class _ColorDisplay extends ConsumerWidget {
  const _ColorDisplay(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

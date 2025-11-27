import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/presentation/screens/widgets/carousel_widget.dart';

class ChoiceScreen extends ConsumerWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: CarouselWidget(
          itemCount: 3, // 원하는 아이템 개수
        ),
      ),
    );
  }
}

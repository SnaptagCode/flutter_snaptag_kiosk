import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class TripleTapFloatingButton extends ConsumerStatefulWidget {
  const TripleTapFloatingButton({super.key});

  @override
  ConsumerState<TripleTapFloatingButton> createState() => _TripleTapFloatingButtonState();
}

class _TripleTapFloatingButtonState extends ConsumerState<TripleTapFloatingButton> {
  final List<DateTime> _tapTimes = [];

  void _handleTap(BuildContext context) {
    final now = DateTime.now();

    // 2초가 지난 탭은 제거
    _tapTimes.removeWhere(
      (tapTime) => now.difference(tapTime) > const Duration(seconds: 2),
    );

    // 현재 탭 추가
    _tapTimes.add(now);

    // 2초 이내 3번 탭되었는지 확인
    if (_tapTimes.length >= 3) {
      _tapTimes.clear(); // 탭 기록 초기화
      KioskInfoRouteData().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _handleTap(context),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: const SizedBox.shrink(),
    );
  }
}

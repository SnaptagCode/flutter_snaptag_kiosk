import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/presentation/banner.dart';

class GlobalShell extends ConsumerWidget {
  final Widget child;

  const GlobalShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          AspectRatio(
            aspectRatio: 9 / 16,
            child: child,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BannerMarquee(
              height: 45, // 배너 높이
              speedPxPerSec: 120.0, // 이동 속도 (px/s)
              backgroundColor: const Color(0xFF111111),
              image: const AssetImage('assets/images/banner.webp'),
              // 또는: NetworkImage('https://.../your_banner.png')
            ),
          )
        ],
      ),
    );
  }
}

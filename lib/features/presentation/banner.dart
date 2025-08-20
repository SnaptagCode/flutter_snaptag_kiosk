import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 하단 띠 광고 - 오른쪽→왼쪽 무한 스크롤 배너
class BannerMarquee extends StatefulWidget {
  const BannerMarquee({
    super.key,
    required this.image,
    this.height = 30,
    this.speedPxPerSec = 100.0,
    this.backgroundColor = Colors.black,
    this.gap = 0.0,
    this.opacity = 1.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    this.borderRadius = const BorderRadius.only(),
  });

  final ImageProvider image;
  final double height;
  final double speedPxPerSec; // 배너 이동 속도(px/sec)
  final Color backgroundColor;
  final double gap; // 이미지 사이 간격 (연결부 여백)
  final double opacity;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  @override
  State<BannerMarquee> createState() => _BannerMarqueeState();
}

class _BannerMarqueeState extends State<BannerMarquee> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim; // 0..1 구간 반복

  // 성능: 30fps로 제한(필요시 24까지도 OK)
  static const _targetFps = 30;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(vsync: this);
    _anim = _ctrl.drive(Tween<double>(begin: 0, end: 1));
    _start();
  }

  void _start() {
    // 프레임 스로틀: 30fps 간격으로 수동 tick
    Duration last = Duration.zero;
    _ctrl.addListener(() {});
    _tick(last);
  }

  void _tick(Duration last) async {
    final frame = Duration(milliseconds: (1000 / _targetFps).round());
    while (mounted) {
      _ctrl.notifyListeners(); // 리스너 호출(AnimatedBuilder 갱신용)
      await Future.delayed(frame);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height.clamp(1, double.infinity).toDouble();
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, c) {
          final width = (c.hasBoundedWidth ? c.maxWidth : MediaQuery.of(context).size.width).isFinite
              ? (c.hasBoundedWidth ? c.maxWidth : MediaQuery.of(context).size.width)
              : 1.0;
          final tileW = (width + widget.gap).clamp(1, double.infinity);

          // ① 정적 child: 이미지 타일 2장 (RepaintBoundary로 래스터 캐시 유도)
          final tiles = RepaintBoundary(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BannerTile(image: widget.image, w: width, h: height),
                if (widget.gap > 0) SizedBox(width: widget.gap),
                _BannerTile(image: widget.image, w: width, h: height),
              ],
            ),
          );

          // ② dx만 애니메이션: modulo로 무한 스크롤
          return ClipRRect(
            borderRadius: widget.borderRadius,
            child: ColoredBox(
              color: widget.backgroundColor.withOpacity(widget.opacity),
              child: AnimatedBuilder(
                animation: _anim,
                child: tiles,
                builder: (context, child) {
                  // 속도(px/s) × 프레임 간격(1/_targetFps)
                  final step = widget.speedPxPerSec / _targetFps;
                  // 누적 이동량을 타일 폭으로 모듈러
                  _dx = (_dx + step) % tileW;
                  final dx = -_dx;

                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  double _dx = 0;
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.image, required this.w, required this.h});
  final ImageProvider image;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    // 성능 포인트
    // - FilterQuality.none : 샘플링 비용 최소화
    // - ResizeImage로 디코딩 사이즈를 배너 높이에 맞춤(Windows에서도 적용됨)
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetH = (h * dpr).round().clamp(1, 4096); // 과도한 디코딩 방지
    final targetW = (w * dpr).round().clamp(1, 8192);

    final sized = ResizeImage(image, width: targetW, height: targetH);

    return SizedBox(
      width: w,
      height: h,
      child: Image(
        image: sized,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none, // 🔧 성능 우선
        isAntiAlias: false,
      ),
    );
  }
}

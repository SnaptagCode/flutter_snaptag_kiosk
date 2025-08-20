import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 하단 띠 광고 - 오른쪽→왼쪽 무한 스크롤 배너
class BannerMarquee extends StatefulWidget {
  const BannerMarquee({
    super.key,
    required this.image,
    this.height = 40,
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
  late final AnimationController _controller;
  late final Ticker _ticker;

  // 현재 오프셋(px)
  double _offset = 0;
  double? _prevElapsedSec;

  @override
  void initState() {
    super.initState();

    // ✅ 여기서 런타임 체크
    assert(!widget.height.isNaN && widget.height.isFinite && widget.height >= 0);
    assert(!widget.speedPxPerSec.isNaN && widget.speedPxPerSec.isFinite);
    assert(!widget.gap.isNaN && widget.gap.isFinite);

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final nowSec = elapsed.inMicroseconds / 1e6;
    var dt = (_prevElapsedSec == null) ? 0.0 : (nowSec - _prevElapsedSec!);
    _prevElapsedSec = nowSec;

    // dt 안전 가드
    if (!dt.isFinite || dt < 0) dt = 0.0;

    final move = widget.speedPxPerSec * dt;
    if (!move.isFinite) return;

    setState(() {
      _offset += move;
      // 수치 안정화: 너무 커지면 주기적으로 감산
      if (!_offset.isFinite) {
        _offset = 0.0;
      } else if (_offset > 1e9) {
        _offset -= 1e9;
      } else if (_offset < -1e9) {
        _offset += 1e9;
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 높이/불투명도도 안전 가드
    final safeHeight = (widget.height.isFinite && widget.height >= 0) ? widget.height : 80.0;
    final bgColor = widget.backgroundColor.withOpacity(
      (widget.opacity.isFinite && widget.opacity >= 0 && widget.opacity <= 1) ? widget.opacity : 1.0,
    );

    return RepaintBoundary(
      child: SizedBox(
        height: safeHeight,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: ColoredBox(
            color: bgColor,
            child: Padding(
              padding: widget.padding,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 폭 계산 (무한대/음수 가드)
                  double width = constraints.hasBoundedWidth ? constraints.maxWidth : MediaQuery.of(context).size.width;
                  if (!width.isFinite || width <= 0) {
                    width = MediaQuery.of(context).size.width;
                    if (!width.isFinite || width <= 0) width = 1.0; // 최종 안전값
                  }

                  // 타일 폭 (gap 포함) 가드
                  final rawTileW = width + (widget.gap.isFinite ? widget.gap : 0.0);
                  final tileW = (rawTileW.isFinite && rawTileW > 0) ? rawTileW : math.max(1.0, width);

                  // dx 계산 가드
                  double dx = 0.0;
                  if (tileW.isFinite && tileW > 0) {
                    final mod = _offset % tileW;
                    dx = (mod.isFinite ? -mod : 0.0);
                  }

                  // 최종 안전 보정
                  if (!dx.isFinite) dx = 0.0;

                  Widget tile() => SizedBox(
                        width: width,
                        height: safeHeight,
                        child: Image(
                          image: widget.image,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        ),
                      );

                  final twoTileX = dx + tileW;
                  final threeTileX = dx + 2 * tileW;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Transform.translate(
                        offset: Offset(dx.isFinite ? dx : 0.0, 0),
                        child: tile(),
                      ),
                      Transform.translate(
                        offset: Offset(twoTileX.isFinite ? twoTileX : (dx + width), 0),
                        child: tile(),
                      ),
                      if (threeTileX.isFinite && threeTileX < width + 1)
                        Transform.translate(
                          offset: Offset(threeTileX, 0),
                          child: tile(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

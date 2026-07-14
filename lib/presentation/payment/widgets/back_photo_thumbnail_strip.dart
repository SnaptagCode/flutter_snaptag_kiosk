import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/widgets/back_photo_images.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/widgets/selection_effects.dart';

/// 고정 뒷면 썸네일 가로 스트립 (한화 다중 이미지 전용).
///
/// 스크롤 상태를 스스로 관리한다 — 스크롤 여지가 있는 쪽에만 엣지 페이드와
/// 화살표를 보여주고, 썸네일 탭 시 해당 항목을 중앙으로 스크롤한 뒤 [onSelect]를 부른다.
class BackPhotoThumbnailStrip extends StatefulWidget {
  const BackPhotoThumbnailStrip({
    super.key,
    required this.cards,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<NominatedBackPhotoCard> cards;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  State<BackPhotoThumbnailStrip> createState() => _BackPhotoThumbnailStripState();
}

class _BackPhotoThumbnailStripState extends State<BackPhotoThumbnailStrip> {
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final target = (position.pixels + delta).clamp(position.minScrollExtent, position.maxScrollExtent);
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: SelectionMotion.curve,
    );
  }

  bool _updateEdgeFades(ScrollMetrics metrics) {
    const tolerance = 1.0;
    final canLeft = metrics.pixels > metrics.minScrollExtent + tolerance;
    final canRight = metrics.pixels < metrics.maxScrollExtent - tolerance;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);
    // 단위는 전부 .r — 키오스크(1080×1920)에선 .w/.h와 동일, 단위가 섞이면 비율이 다른 창에서 정렬이 깨진다
    final double thumbSize = 118.r;
    final double thumbGap = 40.r;
    final double sidePadding = 12.r;

    return SizedBox(
      height: thumbSize + 28.r,
      child: Row(
        children: [
          SizedBox(
            width: 72.r,
            child: Center(
              child: _buildArrow(
                isLeft: true,
                visible: _canScrollLeft,
                onTap: () => _scrollBy(-3 * (thumbSize + thumbGap)),
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: (n) => _updateEdgeFades(n.metrics),
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) => _updateEdgeFades(n.metrics),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    final fade = ((thumbSize * 0.55) / bounds.width).clamp(0.0, 0.25);
                    return LinearGradient(
                      colors: [
                        _canScrollLeft ? Colors.white.withValues(alpha: 0) : Colors.white,
                        Colors.white,
                        Colors.white,
                        _canScrollRight ? Colors.white.withValues(alpha: 0) : Colors.white,
                      ],
                      stops: [0, fade, 1 - fade, 1],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Center(
                    child: ListView.separated(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      itemCount: widget.cards.length,
                      separatorBuilder: (_, __) => SizedBox(width: thumbGap),
                      itemBuilder: (context, index) {
                        return Center(
                          child: Builder(
                            builder: (itemContext) => _buildItem(
                              itemContext: itemContext,
                              index: index,
                              buttonColor: buttonColor,
                              size: thumbSize,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 72.r,
            child: Center(
              child: _buildArrow(
                isLeft: false,
                visible: _canScrollRight,
                onTap: () => _scrollBy(3 * (thumbSize + thumbGap)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow({
    required bool isLeft,
    required bool visible,
    required VoidCallback onTap,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: SelectionMotion.duration,
      curve: SelectionMotion.curve,
      child: IgnorePointer(
        ignoring: !visible,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 64.r,
            height: 96.r,
            child: Center(
              child: Icon(
                isLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                size: 48.r,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 8.r),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required BuildContext itemContext,
    required int index,
    required Color buttonColor,
    required double size,
  }) {
    final card = widget.cards[index];
    final isSelected = index == widget.selectedIndex;

    return GestureDetector(
      onTap: () {
        widget.onSelect(index);
        // 탭한 썸네일을 스트립 중앙으로
        Scrollable.ensureVisible(
          itemContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: SelectionMotion.curve,
        );
      },
      child: SelectionTransition(
        isSelected: isSelected,
        unselectedScale: 0.9,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SelectionRing(
                isSelected: isSelected,
                color: buttonColor,
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CoverNetworkImage(card.originUrl),
                      AnimatedOpacity(
                        opacity: isSelected ? 0.0 : 0.45,
                        duration: SelectionMotion.duration,
                        curve: SelectionMotion.curve,
                        child: const ColoredBox(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: SelectionCheckBadge(
                  visible: isSelected,
                  size: 30.r,
                  color: buttonColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

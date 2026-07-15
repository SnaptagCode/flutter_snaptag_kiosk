import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 선택 강조 모션 값. 썸네일/스타일 카드가 같은 리듬으로 움직이도록 공유한다.
class SelectionMotion {
  const SelectionMotion._();

  static const Duration duration = Duration(milliseconds: 180);
  static const Curve curve = Curves.easeOutCubic;

  static const Curve badgeCurve = Curves.easeOutBack;
}

/// 선택/비선택을 크기와 투명도로 함께 전환하는 공용 애니메이터.
///
/// 암시적 애니메이션이라 부모가 리빌드돼도 진행 중인 전환이 끊기지 않는다.
/// (AnimatedSwitcher처럼 key로 서브트리를 갈아끼우면 Image.network가 매번
/// 새로 붙고 이전/다음 카드가 겹쳐 보인다.)
class SelectionTransition extends StatelessWidget {
  const SelectionTransition({
    super.key,
    required this.isSelected,
    required this.child,
    this.unselectedScale = 0.92,
    this.unselectedOpacity = 1.0,
  });

  final bool isSelected;
  final Widget child;

  /// 비선택 시 축소 배율
  final double unselectedScale;

  /// 비선택 시 투명도. 1.0이면 투명도는 건드리지 않는다.
  final double unselectedOpacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.0 : unselectedScale,
      duration: SelectionMotion.duration,
      curve: SelectionMotion.curve,
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : unselectedOpacity,
        duration: SelectionMotion.duration,
        curve: SelectionMotion.curve,
        child: child,
      ),
    );
  }
}

/// 선택된 항목을 감싸는 링 + 글로우.
///
/// 원형(썸네일)과 라운드 사각(스타일 카드)이 같은 강조 언어를 쓰도록 공용화했다.
/// [borderRadius]가 null이면 원형으로 그린다.
class SelectionRing extends StatelessWidget {
  const SelectionRing({
    super.key,
    required this.isSelected,
    required this.color,
    required this.child,
    this.borderRadius,
    this.restShadow,
  });

  final bool isSelected;
  final Color color;
  final Widget child;
  final BorderRadius? borderRadius;

  /// 비선택 상태에서 유지할 그림자. null이면 그림자 없음.
  final List<BoxShadow>? restShadow;

  static double get ringWidth => 3.r;
  static double get ringGap => 4.r;

  /// 링이 내용물 바깥으로 차지하는 두께 (테두리 + 간격)
  static double get inset => ringWidth + ringGap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: SelectionMotion.duration,
      curve: SelectionMotion.curve,
      // 링 두께와 간격은 선택 여부와 무관하게 항상 자리를 차지해야
      // 내용물이 찌그러지거나 크기가 튀지 않는다.
      padding: EdgeInsets.all(ringGap),
      decoration: BoxDecoration(
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: ringWidth,
        ),
        // 이벤트 배경 사진 위에서도 선택이 드러나도록 링 바깥으로 번지게 한다.
        boxShadow: isSelected
            ? [
                BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 8.r),
                BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 20.r, spreadRadius: 2.r),
              ]
            : restShadow,
      ),
      child: child,
    );
  }
}

/// 선택된 항목에 튕기듯 나타나는 체크 배지.
class SelectionCheckBadge extends StatelessWidget {
  const SelectionCheckBadge({
    super.key,
    required this.visible,
    required this.size,
    required this.color,
  });

  final bool visible;
  final double size;

  /// 배지 바탕색(이벤트 테마의 buttonColor)
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.0,
      duration: SelectionMotion.duration,
      curve: SelectionMotion.badgeCurve,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6.r, offset: Offset(0, 2.r)),
          ],
        ),
        child: Icon(Icons.check_rounded, size: size * 0.55, color: Colors.white),
      ),
    );
  }
}

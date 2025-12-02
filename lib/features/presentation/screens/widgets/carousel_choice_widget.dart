import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';

/// 기획안 6: 회전목마 방식
/// 회전목마로 여러 카드를 보여주고 고정/커스텀 뒷면 선택
class CarouselChoiceWidget extends StatefulWidget {
  final VoidCallback? onFixedSelected;
  final VoidCallback? onCustomSelected;
  final String? frontImagePath;
  final String? fixedBackImagePath;
  final String? customBackImagePath;
  final int itemCount;

  const CarouselChoiceWidget({
    super.key,
    this.onFixedSelected,
    this.onCustomSelected,
    this.frontImagePath,
    this.fixedBackImagePath,
    this.customBackImagePath,
    this.itemCount = 3,
  });

  @override
  State<CarouselChoiceWidget> createState() => _CarouselChoiceWidgetState();
}

class _CarouselChoiceWidgetState extends State<CarouselChoiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;
  bool _isFixedMode = true; // true: 고정, false: 커스텀
  bool _showBack = false; // 현재 뒷면 표시 여부

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotateCarousel() {
    if (_controller.isAnimating) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.itemCount;
      _showBack = false; // 회전 시 앞면으로 리셋
    });

    _controller.forward(from: 0);
  }

  void _flipCurrentCard() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  void _switchMode(bool isFixed) {
    setState(() {
      _isFixedMode = isFixed;
      _showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kioskColors = context.kioskColors;
    final typography = context.typography;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 모드 선택 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton(
              context,
              '고정 뒷면',
              true,
              kioskColors,
              typography,
            ),
            SizedBox(width: 30.w),
            _buildModeButton(
              context,
              '커스텀 뒷면',
              false,
              kioskColors,
              typography,
            ),
          ],
        ),
        SizedBox(height: 40.h),
        // 회전목마 영역
        GestureDetector(
          onTap: _rotateCarousel,
          child: SizedBox(
            height: 600.h,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(widget.itemCount, (index) {
                    return _buildCarouselItem(index, kioskColors);
                  }),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // 안내 텍스트
        Text(
          '회전목마를 탭하여 회전 | 카드를 탭하여 뒷면 보기',
          style: typography.kioskBody2B.copyWith(
            color: Colors.grey[600],
            fontSize: 22.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40.h),
        // 선택 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isFixedMode ? widget.onFixedSelected : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFixedMode
                    ? kioskColors.buttonColor
                    : Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 20.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '고정 뒷면 선택',
                style: typography.kioskBtn1B.copyWith(
                  color: _isFixedMode
                      ? kioskColors.buttonTextColor
                      : Colors.grey[600],
                ),
              ),
            ),
            SizedBox(width: 20.w),
            ElevatedButton(
              onPressed: !_isFixedMode ? widget.onCustomSelected : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isFixedMode
                    ? kioskColors.buttonColor
                    : Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 20.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '커스텀 뒷면 선택',
                style: typography.kioskBtn1B.copyWith(
                  color: !_isFixedMode
                      ? kioskColors.buttonTextColor
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    bool isFixed,
    KioskColors colors,
    KioskTypography typography,
  ) {
    final isSelected = _isFixedMode == isFixed;
    return GestureDetector(
      onTap: () => _switchMode(isFixed),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.buttonColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? colors.buttonColor : Colors.grey[400]!,
            width: 2.w,
          ),
        ),
        child: Text(
          label,
          style: typography.kioskBody2B.copyWith(
            color: isSelected ? colors.buttonTextColor : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(int index, KioskColors kioskColors) {
    final itemCount = widget.itemCount;

    // 현재 인덱스로부터의 상대적 위치 계산
    int relativePosition = (index - _currentIndex) % itemCount;
    if (relativePosition < 0) relativePosition += itemCount;

    // 애니메이션 진행에 따른 위치 조정
    final animatedPosition = relativePosition - _animation.value;

    // 원형 배치를 위한 각도 계산
    final angle = (animatedPosition * 2 * math.pi) / itemCount;

    // 중심 아이템 판단
    final distanceFromCenter = (animatedPosition % itemCount).abs();
    final normalizedDistance = distanceFromCenter > itemCount / 2
        ? itemCount - distanceFromCenter
        : distanceFromCenter;

    // Scale 계산 (중심: 1.0, 나머지: 0.6)
    final scale =
        0.5 + (0.5 * (1 - (normalizedDistance / (itemCount / 2)).clamp(0.0, 1.0)));

    // 투명도 계산 (중심: 1.0, 나머지: 0.4)
    final opacity = normalizedDistance < 0.3 ? 1.0 : 0.4;

    // 원형 배치를 위한 X, Y 오프셋 계산
    final radius = 250.w;
    final xOffset = math.sin(angle) * radius;
    final yOffset = (math.cos(angle) - 1) * 80.h;

    final isCenter = normalizedDistance < 0.3;

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 200.w + xOffset,
      top: 100.h + yOffset,
      child: GestureDetector(
        onTap: isCenter ? _flipCurrentCard : null,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 400.w,
              height: 560.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      (0.2 * (1 - (normalizedDistance / (itemCount / 2))
                              .clamp(0.0, 1.0)))
                          .clamp(0.0, 0.3),
                    ),
                    blurRadius: (20.w *
                            (1 - (normalizedDistance / (itemCount / 2))
                                .clamp(0.0, 1.0)))
                        .clamp(0.0, 20.w),
                    spreadRadius: (4.w *
                            (1 - (normalizedDistance / (itemCount / 2))
                                .clamp(0.0, 1.0)))
                        .clamp(0.0, 4.w),
                  ),
                ],
                border: isCenter
                    ? Border.all(
                        color: kioskColors.buttonColor,
                        width: 3.w,
                      )
                    : null,
              ),
              child: isCenter && _showBack
                  ? _buildBackCard()
                  : _buildFrontCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: widget.frontImagePath != null
          ? Image.asset(
              widget.frontImagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder('앞면'),
            )
          : _buildPlaceholder('앞면'),
    );
  }

  Widget _buildBackCard() {
    final backImagePath = _isFixedMode
        ? widget.fixedBackImagePath
        : widget.customBackImagePath;
    final label = _isFixedMode ? '고정 뒷면' : '커스텀 뒷면';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: backImagePath != null
          ? Image.asset(
              backImagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(label),
            )
          : _buildPlaceholder(label),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 80.sp, color: Colors.grey[400]),
            SizedBox(height: 20.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 24.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';

/// 기획안 5: 3D 회전 방식
/// 3D 회전으로 앞면/뒷면을 보여주고 선택
class Rotate3DChoiceWidget extends StatefulWidget {
  final VoidCallback? onFixedSelected;
  final VoidCallback? onCustomSelected;
  final String? frontImagePath;
  final String? fixedBackImagePath;
  final String? customBackImagePath;

  const Rotate3DChoiceWidget({
    super.key,
    this.onFixedSelected,
    this.onCustomSelected,
    this.frontImagePath,
    this.fixedBackImagePath,
    this.customBackImagePath,
  });

  @override
  State<Rotate3DChoiceWidget> createState() => _Rotate3DChoiceWidgetState();
}

class _Rotate3DChoiceWidgetState extends State<Rotate3DChoiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isFixedMode = true;
  bool _isAutoRotating = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleAutoRotate() {
    setState(() {
      _isAutoRotating = !_isAutoRotating;
      if (_isAutoRotating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void _switchMode(bool isFixed) {
    setState(() {
      _isFixedMode = isFixed;
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
        // 3D 회전 카드
        GestureDetector(
          onTap: _toggleAutoRotate,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_rotationAnimation.value),
                child: _rotationAnimation.value % (2 * math.pi) < math.pi
                    ? _buildFrontCard(context, kioskColors, typography)
                    : _buildBackCard(context, kioskColors, typography),
              );
            },
          ),
        ),
        SizedBox(height: 30.h),
        // 안내 텍스트
        Text(
          _isAutoRotating
              ? '자동 회전 중 (탭하여 일시정지)'
              : '탭하여 회전 재개',
          style: typography.kioskBody2B.copyWith(
            color: Colors.grey[600],
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

  Widget _buildFrontCard(
    BuildContext context,
    KioskColors colors,
    KioskTypography typography,
  ) {
    return Container(
      width: 400.w,
      height: 560.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25.w,
            spreadRadius: 5.w,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: widget.frontImagePath != null
            ? Image.asset(
                widget.frontImagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder('앞면'),
              )
            : _buildPlaceholder('앞면'),
      ),
    );
  }

  Widget _buildBackCard(
    BuildContext context,
    KioskColors colors,
    KioskTypography typography,
  ) {
    final backImagePath = _isFixedMode
        ? widget.fixedBackImagePath
        : widget.customBackImagePath;
    final label = _isFixedMode ? '고정 뒷면' : '커스텀 뒷면';

    return Container(
      width: 400.w,
      height: 560.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25.w,
            spreadRadius: 5.w,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: backImagePath != null
            ? Image.asset(
                backImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(label),
              )
            : _buildPlaceholder(label),
      ),
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


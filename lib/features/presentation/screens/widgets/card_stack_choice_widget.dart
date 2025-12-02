import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';

/// 기획안 4: 카드 스택 방식
/// 카드가 쌓여있는 형태로 보여주고 선택
class CardStackChoiceWidget extends StatefulWidget {
  final VoidCallback? onFixedSelected;
  final VoidCallback? onCustomSelected;
  final String? frontImagePath;
  final String? fixedBackImagePath;
  final String? customBackImagePath;

  const CardStackChoiceWidget({
    super.key,
    this.onFixedSelected,
    this.onCustomSelected,
    this.frontImagePath,
    this.fixedBackImagePath,
    this.customBackImagePath,
  });

  @override
  State<CardStackChoiceWidget> createState() => _CardStackChoiceWidgetState();
}

class _CardStackChoiceWidgetState extends State<CardStackChoiceWidget> {
  int? _selectedIndex; // 0: 고정, 1: 커스텀

  @override
  Widget build(BuildContext context) {
    final kioskColors = context.kioskColors;
    final typography = context.typography;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 제목
        Text(
          '뒷면 이미지 선택',
          style: typography.kioskBody1B,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        Text(
          '카드를 탭하여 선택하세요',
          style: typography.kioskBody2B.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 50.h),
        // 카드 스택 영역
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStackCard(
              context,
              index: 0,
              title: '고정 뒷면',
              backImagePath: widget.fixedBackImagePath,
              frontImagePath: widget.frontImagePath,
              kioskColors: kioskColors,
              typography: typography,
            ),
            SizedBox(width: 60.w),
            _buildStackCard(
              context,
              index: 1,
              title: '커스텀 뒷면',
              backImagePath: widget.customBackImagePath,
              frontImagePath: widget.frontImagePath,
              kioskColors: kioskColors,
              typography: typography,
            ),
          ],
        ),
        SizedBox(height: 50.h),
        // 선택 버튼
        ElevatedButton(
          onPressed: _selectedIndex != null
              ? (_selectedIndex == 0
                  ? widget.onFixedSelected
                  : widget.onCustomSelected)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedIndex != null
                ? kioskColors.buttonColor
                : Colors.grey[300],
            padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 25.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            _selectedIndex == null
                ? '뒷면을 선택해주세요'
                : _selectedIndex == 0
                    ? '고정 뒷면으로 진행'
                    : '커스텀 뒷면으로 진행',
            style: typography.kioskBtn1B.copyWith(
              color: _selectedIndex != null
                  ? kioskColors.buttonTextColor
                  : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackCard(
    BuildContext context, {
    required int index,
    required String title,
    String? backImagePath,
    String? frontImagePath,
    required KioskColors kioskColors,
    required KioskTypography typography,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        children: [
          // 카드 스택
          Stack(
            alignment: Alignment.center,
            children: [
              // 뒷면 카드 (가장 아래)
              Transform.translate(
                offset: Offset(15.w, 15.h),
                child: Transform.rotate(
                  angle: 0.05,
                  child: Container(
                    width: 320.w,
                    height: 448.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      color: Colors.grey[300],
                      border: Border.all(
                        color: isSelected
                            ? kioskColors.buttonColor.withOpacity(0.5)
                            : Colors.grey[400]!,
                        width: 2.w,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: backImagePath != null
                          ? Image.asset(
                              backImagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder('뒷면'),
                            )
                          : _buildPlaceholder('뒷면'),
                    ),
                  ),
                ),
              ),
              // 앞면 카드 (가장 위)
              Transform.rotate(
                angle: -0.02,
                child: Container(
                  width: 320.w,
                  height: 448.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15.w,
                        spreadRadius: 2.w,
                      ),
                    ],
                    border: Border.all(
                      color: isSelected
                          ? kioskColors.buttonColor
                          : Colors.transparent,
                      width: isSelected ? 4.w : 0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: frontImagePath != null
                        ? Image.asset(
                            frontImagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholder('앞면'),
                          )
                        : _buildPlaceholder('앞면'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          // 제목
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? kioskColors.buttonColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              title,
              style: typography.kioskBody2B.copyWith(
                color: isSelected
                    ? kioskColors.buttonTextColor
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
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
            Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
            SizedBox(height: 15.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 20.sp,
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


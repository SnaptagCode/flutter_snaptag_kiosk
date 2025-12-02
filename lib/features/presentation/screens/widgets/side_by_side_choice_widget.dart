import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';

/// 기획안 2: 나란히 비교 방식
/// 고정 뒷면과 커스텀 뒷면을 나란히 보여주고 선택
class SideBySideChoiceWidget extends StatefulWidget {
  final VoidCallback? onFixedSelected;
  final VoidCallback? onCustomSelected;
  final String? frontImagePath;
  final String? fixedBackImagePath;
  final String? customBackImagePath;

  const SideBySideChoiceWidget({
    super.key,
    this.onFixedSelected,
    this.onCustomSelected,
    this.frontImagePath,
    this.fixedBackImagePath,
    this.customBackImagePath,
  });

  @override
  State<SideBySideChoiceWidget> createState() => _SideBySideChoiceWidgetState();
}

class _SideBySideChoiceWidgetState extends State<SideBySideChoiceWidget> {
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
          '뒷면 이미지를 선택하세요',
          style: typography.kioskBody1B,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 50.h),
        // 카드 비교 영역
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardOption(
              context,
              index: 0,
              title: '고정 뒷면',
              description: '미리 준비된\n뒷면 이미지',
              backImagePath: widget.fixedBackImagePath,
              frontImagePath: widget.frontImagePath,
              kioskColors: kioskColors,
              typography: typography,
            ),
            SizedBox(width: 40.w),
            _buildCardOption(
              context,
              index: 1,
              title: '커스텀 뒷면',
              description: '직접 업로드한\n뒷면 이미지',
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

  Widget _buildCardOption(
    BuildContext context, {
    required int index,
    required String title,
    required String description,
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
          // 카드 스택 (앞면 + 뒷면)
          Stack(
            alignment: Alignment.center,
            children: [
              // 뒷면 카드
              Transform.translate(
                offset: Offset(10.w, 10.h),
                child: Container(
                  width: 350.w,
                  height: 490.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Colors.grey[300],
                    border: Border.all(
                      color: isSelected
                          ? kioskColors.buttonColor
                          : Colors.grey[400] ?? Colors.grey,
                      width: isSelected ? 4.w : 2.w,
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
              // 앞면 카드
              Container(
                width: 350.w,
                height: 490.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20.w,
                      spreadRadius: 4.w,
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
            ],
          ),
          SizedBox(height: 20.h),
          // 제목
          Text(
            title,
            style: typography.kioskBody2B.copyWith(
              color: isSelected
                  ? kioskColors.buttonColor
                  : kioskColors.textColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          // 설명
          Text(
            description,
            style: typography.kioskBody2B.copyWith(
              fontSize: 22.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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


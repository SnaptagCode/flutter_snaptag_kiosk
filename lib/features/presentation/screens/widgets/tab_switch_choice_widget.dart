import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';

/// 기획안 3: 탭 전환 방식
/// 탭으로 고정/커스텀을 전환하며 각각의 뒷면 미리보기
class TabSwitchChoiceWidget extends StatefulWidget {
  final VoidCallback? onFixedSelected;
  final VoidCallback? onCustomSelected;
  final String? frontImagePath;
  final String? fixedBackImagePath;
  final String? customBackImagePath;

  const TabSwitchChoiceWidget({
    super.key,
    this.onFixedSelected,
    this.onCustomSelected,
    this.frontImagePath,
    this.fixedBackImagePath,
    this.customBackImagePath,
  });

  @override
  State<TabSwitchChoiceWidget> createState() => _TabSwitchChoiceWidgetState();
}

class _TabSwitchChoiceWidgetState extends State<TabSwitchChoiceWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kioskColors = context.kioskColors;
    final typography = context.typography;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 탭 바
        Container(
          width: 600.w,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: kioskColors.buttonColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            labelColor: kioskColors.buttonTextColor,
            unselectedLabelColor: Colors.grey[700],
            labelStyle: typography.kioskBody2B.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: typography.kioskBody2B,
            onTap: (index) {
              setState(() {
                _showBack = false;
              });
            },
            tabs: const [
              Tab(text: '고정 뒷면'),
              Tab(text: '커스텀 뒷면'),
            ],
          ),
        ),
        SizedBox(height: 40.h),
        // 카드 미리보기 영역
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCardPreview(
                context,
                isFixed: true,
                kioskColors: kioskColors,
                typography: typography,
              ),
              _buildCardPreview(
                context,
                isFixed: false,
                kioskColors: kioskColors,
                typography: typography,
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        // 선택 버튼
        ElevatedButton(
          onPressed: _tabController.index == 0
              ? widget.onFixedSelected
              : widget.onCustomSelected,
          style: ElevatedButton.styleFrom(
            backgroundColor: kioskColors.buttonColor,
            padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 25.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            _tabController.index == 0
                ? '고정 뒷면 선택'
                : '커스텀 뒷면 선택',
            style: typography.kioskBtn1B.copyWith(
              color: kioskColors.buttonTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardPreview(
    BuildContext context, {
    required bool isFixed,
    required KioskColors kioskColors,
    required KioskTypography typography,
  }) {
    final backImagePath =
        isFixed ? widget.fixedBackImagePath : widget.customBackImagePath;
    final title = isFixed ? '고정 뒷면' : '커스텀 뒷면';
    final description = isFixed
        ? '미리 준비된 뒷면 이미지가\n포토카드 뒷면에 인쇄됩니다'
        : '직접 업로드한 뒷면 이미지가\n포토카드 뒷면에 인쇄됩니다';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 설명 텍스트
        Text(
          description,
          style: typography.kioskBody2B.copyWith(
            fontSize: 24.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40.h),
        // 카드 플립 버튼
        GestureDetector(
          onTap: () {
            setState(() {
              _showBack = !_showBack;
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _showBack
                ? _buildBackCard(
                    context,
                    backImagePath,
                    title,
                    kioskColors,
                    typography,
                  )
                : _buildFrontCard(
                    context,
                    widget.frontImagePath,
                    kioskColors,
                    typography,
                  ),
          ),
        ),
        SizedBox(height: 30.h),
        // 플립 안내
        Text(
          _showBack ? '뒷면 미리보기' : '앞면 (탭하여 뒷면 보기)',
          style: typography.kioskBody2B.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFrontCard(
    BuildContext context,
    String? frontImagePath,
    KioskColors kioskColors,
    KioskTypography typography,
  ) {
    return Container(
      key: const ValueKey('front'),
      width: 400.w,
      height: 560.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20.w,
            spreadRadius: 4.w,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: frontImagePath != null
            ? Image.asset(
                frontImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder('앞면'),
              )
            : _buildPlaceholder('앞면'),
      ),
    );
  }

  Widget _buildBackCard(
    BuildContext context,
    String? backImagePath,
    String title,
    KioskColors kioskColors,
    KioskTypography typography,
  ) {
    return Container(
      key: const ValueKey('back'),
      width: 400.w,
      height: 560.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20.w,
            spreadRadius: 4.w,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: backImagePath != null
            ? Image.asset(
                backImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(title),
              )
            : _buildPlaceholder(title),
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


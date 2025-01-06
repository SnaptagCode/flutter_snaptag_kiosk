import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({
    super.key,
    required this.content,
  });

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080.w,
      height: 360.h,
      decoration: BoxDecoration(border: Border.all(color: Colors.transparent, width: 0.w)),
      child: Stack(
        children: [
          // 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent, // 왼쪽 투명한 검정
                  Colors.black.withOpacity(0.08), // 중앙 불투명한 검정
                  Colors.transparent, // 오른쪽 투명한 검정
                ],
                stops: [0.0, 0.5, 1.0], // 색상 분포
              ),
            ),
          ),
          // 중앙 콘텐츠
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.transparent, // 회색 배경
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 둥근 모서리
                      ),
                    ),
                    child: Center(
                      child: content, // 콘텐츠 위젯 삽입
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

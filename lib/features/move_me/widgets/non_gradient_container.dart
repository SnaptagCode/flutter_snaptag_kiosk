import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NonGradientContainer extends StatelessWidget {
  const NonGradientContainer({
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
          // 중앙 콘텐츠
          Row(
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
                  margin: EdgeInsets.symmetric(vertical: 22.h),
                  child: Center(
                    child: content, // 콘텐츠 위젯 삽입
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

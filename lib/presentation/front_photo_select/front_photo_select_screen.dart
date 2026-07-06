import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';

/// 앞면 이미지 선택 화면 (선택형 이벤트 전용)
///
/// 홈 '추천이미지' 진입 시 frontPhotoList의 앞면 후보를 사용자가 직접 고른다.
class FrontPhotoSelectScreen extends ConsumerWidget {
  const FrontPhotoSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '앞면 이미지 선택',
          style: context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40.h),
        // TODO(JKLI-175): Step 2에서 frontPhotoListProvider 그리드로 교체
        Text(
          '(준비 중) 앞면 이미지 리스트가 여기에 표시됩니다',
          style: context.typography.kioskBody1B.copyWith(fontSize: 24.sp, color: mainTextColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 60.h),
        GestureDetector(
          onTap: () => HomeRouteData().go(context),
          child: Container(
            width: 282.w,
            height: 67.h,
            decoration: BoxDecoration(
              color: kiosk?.mainButtonColor.toColor() ?? Colors.black,
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '홈으로',
              style: context.typography.kioskBtn1B.copyWith(
                fontSize: 30.sp,
                color: kiosk?.buttonTextColor.toColor(fallback: Colors.white) ?? Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

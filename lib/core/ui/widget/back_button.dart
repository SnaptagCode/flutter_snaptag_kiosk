import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_mode_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class KioskBackButton extends ConsumerWidget {
  const KioskBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).fullPath;
    if (currentPath == null) {
      return const SizedBox.shrink();
    }

    final isHomeScreen = currentPath == HomeRouteData().location;
    final isPrintProcessScreen = currentPath == PrintProcessRouteData().location;
    final isKioskRoute = currentPath.contains('/kiosk');

    final selection = ref.watch(backPhotoTypeProvider);
    final isFixed = selection?.type == BackPhotoType.fixed;
    final isFrontPhotoUserSelect = ref.watch(isFrontPhotoUserSelectProvider);

    logger.i(
        'KioskBackButton: currentPath: $currentPath isHomeScreen: $isHomeScreen isPrintProcessScreen: $isPrintProcessScreen isKioskRoute: $isKioskRoute');

    // /kiosk 하위 루트에서 home, print-process를 제외한 화면에서만 표시
    if (!isKioskRoute || isHomeScreen || isPrintProcessScreen) {
      return const SizedBox.shrink();
    }

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: 'Cafe24Ssurround2',
      ),
      child: InkWell(
        onTap: () {
          _navigateBack(context, currentPath, isFixed, isFrontPhotoUserSelect);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            color: Colors.white,
          ),
          height: 44.h,
          width: 162.w,
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘은 나중에 추가 예정
                SvgPicture.asset(
                  SnaptagSvg.kioskBack,
                  width: 28.w,
                  height: 28.h,
                ),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  LocaleKeys.common_btn_back.tr(),
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context, String currentPath, bool isFixed, bool isFrontPhotoUserSelect) {
    // 현재 경로에 따라 이전 화면으로 명시적으로 이동
    if (currentPath == CodeVerificationRouteData().location) {
      // /kiosk/code-verification → /kiosk/home
      const HomeRouteData().go(context);
    } else if (currentPath == FrontPhotoSelectRouteData().location) {
      // /kiosk/front-photo-select → /kiosk/home
      const HomeRouteData().go(context);
    } else if (currentPath == PhotoCardPreviewRouteData().location) {
      if (isFixed) {
        // 고정 뒷면: 선택형(USER_SELECT) 이벤트면 앞면 선택 화면으로, 아니면 홈으로 (JKLI-175)
        isFrontPhotoUserSelect ? FrontPhotoSelectRouteData().go(context) : HomeRouteData().go(context);
      } else {
        // 커스텀 뒷면: 인증번호 입력 화면으로
        CodeVerificationRouteData().go(context);
      }
    } else {
      // 기본적으로 pop 시도, 실패 시 홈으로
      if (context.canPop()) {
        context.pop();
      } else {
        const HomeRouteData().go(context);
      }
    }
  }
}

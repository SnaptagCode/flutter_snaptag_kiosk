import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeButton extends ConsumerWidget {
  const HomeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isPrinting = currentPath == PrintProcessRouteData().location;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: 'Cafe24Ssurround2',
      ),
      child: InkWell(
        onTap: isPrinting
            ? null
            : () {
                const HomeRouteData().go(context);
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
                SvgPicture.asset(
                  SnaptagSvg.home,
                  width: 28.w,
                  height: 28.h,
                ),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  'HOME',
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
}

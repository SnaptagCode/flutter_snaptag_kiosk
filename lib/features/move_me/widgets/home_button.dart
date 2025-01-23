import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:go_router/go_router.dart';

class HomeButton extends ConsumerWidget {
  const HomeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isPrinting = currentPath == '/print';

    return Padding(
      padding: EdgeInsets.all(8.0.r),
      child: Container(
        height: 44.h,
        width: 162.w,
        decoration: context.homeNavigationDecoration,
        child: InkWell(
          onTap: isPrinting
              ? null
              : () {
                  const PhotoCardUploadRouteData().go(context);
                },
          child: Image.asset(
            SnaptagImages.iconHome,
          ),
        ),
      ),
    );
  }
}

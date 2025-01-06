import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:loader_overlay/loader_overlay.dart';

class KioskShell extends ConsumerWidget {
  final Widget child;

  const KioskShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AspectRatio(
        aspectRatio: 9 / 16,
        child: Column(
          children: [
            SizedBox(
              height: 855.h,
              width: double.infinity,
              child: Image.network(
                ref.watch(storageServiceProvider).settings.topBannerUrl,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class ContentsShell extends ConsumerWidget {
  final Widget child;

  const ContentsShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoaderOverlay(
      overlayWidgetBuilder: (dynamic progress) {
        return Center(
          child: SizedBox(
            width: 350.w,
            height: 350.h,
            child: CircularProgressIndicator(
              strokeWidth: 15.w,
            ),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              ref.watch(storageServiceProvider).settings.mainImageUrl,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // 앱바 영역
            SizedBox(
              height: 70.h,
              child: Row(
                children: [
                  const Spacer(),
                  KioskNavigatorButton(),
                ],
              ),
            ),
            SizedBox(
              height: 230.h,
            ),
            // 실제 콘텐츠
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

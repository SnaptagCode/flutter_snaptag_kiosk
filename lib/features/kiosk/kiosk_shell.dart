import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KioskShell extends ConsumerWidget {
  final Widget child;

  const KioskShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: child,
      ),
    );
    /*
    return Center(
      child: SizedBox(
        width: 1080.w,
        height: 1920.h,
        child: Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: imageAsync.topBannerSize?.height.h,
                width: imageAsync.topBannerSize?.width.w,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: imageAsync.topBanner != null ? DecorationImage(image: imageAsync.topBanner!) : null),
                    ),
                    HiddenButton(), // 12/26일 배포하지 않기로 결정
                  ],
                ),
              ),
              Container(
                height: imageAsync.mainImageSize?.height.h,
                width: imageAsync.mainImageSize?.width.w,
                decoration: BoxDecoration(
                    image: imageAsync.mainImage != null ? DecorationImage(image: imageAsync.mainImage!) : null),
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 70.h,
                    actions: [
                      Center(
                        child: Builder(builder: (context) {
                          final currentPath = GoRouterState.of(context).matchedLocation;
                          if (currentPath != QRRouteData().location) {
                            return const KioskNavigationBar();
                          } else {
                            return const LocalePopupMenu();
                          }
                        }),
                      ),
                    ],
                  ),
                  body: _WidgetSection(child: child),
                ),
              )
            ],
          ),
        ),
      ),
    );
     */
  }
}

class _TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (140 + 70).h,
    );
  }
}

class _WidgetSection extends StatelessWidget {
  const _WidgetSection({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Column(
          children: [
            _TitleSection(),
            SizedBox(
              height: 20.h,
            ),
            Expanded(child: child)
          ],
        ),
      );
    });
  }
}

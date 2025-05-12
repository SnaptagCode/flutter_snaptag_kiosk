import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/widgets/printer_status_badge.dart';

class KioskShell extends ConsumerWidget {
  final Widget child;

  const KioskShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNetworkError = ref.watch(backgroundImageProvider);
    final settings = ref.read(kioskInfoServiceProvider);
    return Stack(
        children: [
        Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 855.h,
            width: double.infinity,
            child: Image.network(
              ref.read(kioskInfoServiceProvider)?.topBannerUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: const Text('이미지를 찾을 수 없습니다.'),
                );
              },
            ),
          ),
          Expanded(
            child: LoaderOverlay(
              overlayWidgetBuilder: (dynamic progress) {
                return Center(
                  child: SizedBox(
                    width: 350.h,
                    height: 350.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 15.h,
                    ),
                  ),
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: !hasNetworkError
                      ? DecorationImage(
                          image: NetworkImage(settings?.mainImageUrl ?? ''),
                          onError: (Object e, StackTrace? stackTrace) {
                            debugPrint(
                              "Could not load the network image, showing fallback instead. Error: ${e.toString()}",
                            );
                            if (stackTrace != null) {
                              debugPrint(stackTrace.toString());
                            }
                            ref.read(backgroundImageProvider.notifier).setNetworkError();
                          },
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: const AssetImage('assets/images/fallback_body.jpg'),
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
                          SizedBox(width: 30.w),
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
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: TripleTapFloatingButton(),
    ),
        const Positioned(
          top: 20,
          left: 20,
          child: FloatingPrinterStatusBadge(),
        ),
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class PrintProcessScreen extends ConsumerStatefulWidget {
  const PrintProcessScreen({super.key});

  @override
  ConsumerState<PrintProcessScreen> createState() => _PrintProcessScreenState();
}

class _PrintProcessScreenState extends ConsumerState<PrintProcessScreen> {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stopwatch.stop();
      debugPrint('🖨 PrintProcessScreen 렌더링 완료까지: ${_stopwatch.elapsedMilliseconds}ms');
    });
  }

  @override
  Widget build(BuildContext context) {
    /**
         final printProcess = ref.watch(printProcessScreenProviderProvider);
    if (printProcess.isLoading) {
      if (!context.loaderOverlay.visible) context.loaderOverlay.show();
    } else {
      if (context.loaderOverlay.visible) context.loaderOverlay.hide();
    }
     */

    // listen 부분에서는 로딩 오버레이 처리를 제거
    ref.listen(printProcessScreenProviderProvider, (previous, next) async {
      /**
            if (next.isLoading && !context.loaderOverlay.visible) {
        context.loaderOverlay.show();
        return;
      }

      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }
       */

      if (!next.isLoading) {
        // 로딩이 아닐 때만 처리
        await next.when(
          error: (error, stack) async {
            logger.e('Print process error', error: error, stackTrace: stack);

            // 에러 발생 시 환불 처리
            try {
              await ref.read(paymentServiceProvider.notifier).refund();
            } catch (refundError) {
              logger.e('Refund failed', error: refundError);
            }

            await DialogHelper.showPrintErrorDialog(
              context,
              onButtonPressed: () {
                PhotoCardUploadRouteData().go(context);
              },
            );
          },
          loading: () => null,
          data: (_) async {
            await DialogHelper.showPrintCompleteDialog(
              context,
              onButtonPressed: () {
                PhotoCardUploadRouteData().go(context);
              },
            );
          },
        );
      }
    });
    final kiosk = ref.watch(kioskInfoServiceProvider);

    return DefaultTextStyle(
        style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja'?
        'MPLUSRounded' : 'Cafe24Ssurround2',
    ), child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.sub03_txt_01.tr(),
            textAlign: TextAlign.center,
            style: context.typography.kioskBody1B,
          ),
          SizedBox(height: 30.h),
          GradientContainer(
            content: Padding(
              padding: EdgeInsets.all(8.r),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.asset(
                  SnaptagImages.printLoading,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            LocaleKeys.sub03_txt_02.tr(),
            textAlign: TextAlign.center,
            style: context.typography.kioskBody2B,
          ),
          SizedBox(height: 12.h),
          Text(
            LocaleKeys.sub03_txt_03.tr(),
            textAlign: TextAlign.center,
            style: context.typography.kioskBody2B.copyWith(color: Color(int.parse(kiosk?.couponTextColor.replaceFirst('#', '0xff') ?? '0xffffff')),
              //fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    ),);
  }
}

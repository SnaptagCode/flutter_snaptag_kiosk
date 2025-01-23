import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/features/presentation/providers/screens/print_process_screen_provider.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PrintProcessScreen extends ConsumerWidget {
  const PrintProcessScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(
      printProcessProvider,
      (previous, next) async {
        if (next.isLoading) {
          context.loaderOverlay.show();
          return;
        }

        if (context.loaderOverlay.visible) {
          context.loaderOverlay.hide();
        }

        await next.when(
          error: (error, stack) async {
            logger.e('Print process error', error: error, stackTrace: stack);

            await DialogHelper.showCustomDialog(
              context,
              title: '오류',
              message: error.toString(),
              buttonText: 'OK',
            );
          },
          loading: () => null,
          data: (_) async {
            await DialogHelper.showPrintCompleteDialog(context);
          },
        );
      },
    );
    return Center(
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
        ],
      ),
    );
  }
}

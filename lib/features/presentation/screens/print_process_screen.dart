import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

import 'dart:io';
import 'dart:math';

class PrintProcessScreen extends ConsumerStatefulWidget {
  const PrintProcessScreen({super.key});

  @override
  ConsumerState<PrintProcessScreen> createState() => _PrintProcessScreenState();
}

class _PrintProcessScreenState extends ConsumerState<PrintProcessScreen> {
  @override
  Widget build(BuildContext context) {
    final randomAdImage = getRandomAdImagePath();

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
            final machineId =
                ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
            SlackLogService().sendErrorLogToSlack(
                'Machine ID: $machineId, Print process error\nError: $error');
            SlackLogService()
                .sendErrorLogToSlack('Print process error\nError: $error');
            final errorMessage = error.toString();
            // 에러 발생 시 환불 처리
            try {
              await ref.read(paymentServiceProvider.notifier).refund();
              ref.read(cardCountProvider.notifier).increase();
            } catch (refundError) {
              SlackLogService()
                  .sendErrorLogToSlack('Refund failed \nError: $refundError');
              logger.e('Refund failed', error: refundError);
            }
            if (errorMessage.contains('Card feeder is empty')) {
              if (ref.read(cardCountProvider) < 1) {
                ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
                SlackLogService().sendLogToSlack(
                    'machineId: $machineId, change pagePrintType double');
              } else {
                ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
                SlackLogService().sendLogToSlack(
                    'machineId: $machineId, change pagePrintType single');
              }
              await DialogHelper.showPrintCardRefillDialog(
                context,
                onButtonPressed: () {
                  PhotoCardUploadRouteData().go(context);
                },
              );
            } else {
              if (ref.read(cardCountProvider) < 1) {
                ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
                SlackLogService().sendLogToSlack(
                    'machineId: $machineId, change pagePrintType double');
              } else {
                ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
                SlackLogService().sendLogToSlack(
                    'machineId: $machineId, change pagePrintType single');
              }
              await DialogHelper.showPrintErrorDialog(
                context,
                onButtonPressed: () {
                  PhotoCardUploadRouteData().go(context);
                },
              );
            }
          },
          loading: () => null,
          data: (_) async {
            final machineId =
                ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
            if (ref.read(cardCountProvider) < 1) {
              ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
              SlackLogService().sendLogToSlack(
                  'machineId: $machineId, change pagePrintType double');
            } else {
              ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
              SlackLogService().sendLogToSlack(
                  'machineId: $machineId, change pagePrintType single');
            }
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
    print("랜덤 이미지 : ${randomAdImage}");
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja'
            ? 'MPLUSRounded'
            : 'Cafe24Ssurround2',
      ),
      child: Center(
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
                    (kiosk?.kioskMachineId ?? 4) == 1
                        ? SnaptagImages.printLoading
                        : randomAdImage ?? SnaptagImages.printLoading,
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
              style: context.typography.kioskBody2B.copyWith(
                color: Color(int.parse(
                    kiosk?.couponTextColor.replaceFirst('#', '0xff') ??
                        '0xffffff')),
                //fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 플랫폼별로 실행 파일 기준 adImages 디렉토리를 반환합니다.R

String? getRandomAdImagePath() {
  try {
    // 실행 파일 위치 추출
    final execPath = Platform.resolvedExecutable;
    final execDir = File(execPath).parent;

    // 실행파일과 같은 경로 기준 assets/adImages 폴더 접근
    final adImageDir = Directory('${execDir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}adImages');

    if (!adImageDir.existsSync()) {
      print('[❌] 폴더 없음: ${adImageDir.path}');
      return null;
    }

    final imageFiles = adImageDir
        .listSync()
        .whereType<File>()
        .where((f) =>
            f.path.toLowerCase().endsWith('.png') ||
            f.path.toLowerCase().endsWith('.jpg') ||
            f.path.toLowerCase().endsWith('.jpeg'))
        .toList();

    if (imageFiles.isEmpty) {
      print('[⚠️] 이미지 없음: ${adImageDir.path}');
      return null;
    }

    final fileName = imageFiles[Random().nextInt(imageFiles.length)]
        .uri
        .pathSegments
        .last;

    // 항상 동일한 상대 경로 문자열로 반환
    return 'assets/adImages/$fileName';
  } catch (e) {
    print('[에러] 이미지 불러오기 실패: $e');
    return null;
  }
}
}

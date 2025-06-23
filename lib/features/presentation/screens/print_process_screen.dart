import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/widgets/non_gradient_container.dart';
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
    print("키오스크 번호 : ${(kiosk?.kioskMachineId ?? 1)}");
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
            (kiosk?.kioskMachineId ?? 1) == 1
                ? SizedBox(height: 30.h)
                : SizedBox(
                    height: 0.h,
                  ),

            (kiosk?.kioskMachineId ?? 1) == 1
            ? NonGradientContainer(
              content: Padding(
                padding: EdgeInsets.all(8.r),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: (kiosk?.kioskMachineId ?? 1) == 1
                      ? SizedBox(
                          child: Image.asset(
                            SnaptagImages.printLoading,
                            fit: BoxFit.fill,
                          ),
                        )
                      : Image.asset(
                          randomAdImage ?? SnaptagImages.printLoading,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ) : GradientContainer(
              content: Padding(
                padding: EdgeInsets.all(8.r),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                          child: Image.asset(
                            SnaptagImages.printLoading,
                            fit: BoxFit.fill,
                          ),
                        )
                ),
              ),
            ),
            (kiosk?.kioskMachineId ?? 1) == 1
                ? SizedBox(height: 30.h)
                : SizedBox(
                    height: 0.h,
                  ),
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

  /// .env.version 파일에서 버전 문자열을 동기적으로 읽어옵니다.
  String? getAppVersionSync() {
    try {
      final file = File('assets/.env.version');
      if (!file.existsSync()) {
        print('❌ .env.version 파일이 존재하지 않습니다.');
        return null;
      }
      return file.readAsStringSync().trim();
    } catch (e) {
      print('❌ .env.version 파일 읽기 오류: $e');
      return null;
    }
  }

  /// 사용자 홈 디렉토리를 동기적으로 반환합니다.
  String? getUserDirectorySync() {
    return Platform.environment['USERPROFILE']; // Windows 전용
  }

  /// 최종: 랜덤 이미지 파일 경로 반환
  String? getRandomAdImagePath() {
    final version = getAppVersionSync();
    final userDir = getUserDirectorySync();

    if (version == null || userDir == null) {
      print('❌ 사용자 디렉토리 또는 버전을 불러올 수 없습니다.');
      return null;
    }

    final adImageFolder = Directory(
      '$userDir\\Snaptag\\$version\\assets\\adImages',
    );

    if (!adImageFolder.existsSync()) {
      print('❌ 이미지 폴더가 존재하지 않습니다: ${adImageFolder.path}');
      return null;
    }

    final imageFiles = adImageFolder
        .listSync()
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.png') ||
            f.path.endsWith('.jpg') ||
            f.path.endsWith('.jpeg'))
        .toList();

    if (imageFiles.isEmpty) {
      print('❌ 이미지 파일이 없습니다.');
      return null;
    }

    final randomFile = imageFiles[Random().nextInt(imageFiles.length)];
    final fileName = randomFile.uri.pathSegments.last;

    return 'assets/adImages/$fileName';
  }
}

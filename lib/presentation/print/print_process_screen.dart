import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/providers/version_notifier.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/print_process_screen_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_response_state.dart';

import 'dart:io';
import 'dart:math';

import 'package:flutter_snaptag_kiosk/presentation/payment/payment_service.dart';

class PrintProcessScreen extends ConsumerStatefulWidget {
  const PrintProcessScreen({super.key});

  @override
  ConsumerState<PrintProcessScreen> createState() => _PrintProcessScreenState();
}

class _PrintProcessScreenState extends ConsumerState<PrintProcessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  bool _progressCompleted = false;
  bool _progressFrozen = false;
  bool _networkErrorHandled = false;
  bool _pendingNetworkError = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // API 호출 단계: 0% → 10% 천천히
    _progressController.animateTo(
      0.10,
      duration: const Duration(seconds: 10),
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final randomAdImage = getRandomAdImageFilePath(ref);
    final isHwe = ref.read(kioskInfoServiceProvider)?.isHwe == true;

    // 네트워크 끊김 즉시 감지: Dio 타임아웃 없이 바로 에러 처리
    ref.listen<NetworkState>(networkStatusNotifierProvider, (previous, next) {
      if (_networkErrorHandled) return;
      if (previous?.status == next.status) return;

      final isNetworkDown =
          next.status == NetworkStatus.disconnected || next.status == NetworkStatus.unstable;
      if (!isNetworkDown) return;
      if (_progressCompleted || _progressFrozen) return;
      // 프린터가 이미 실행 중이면 네트워크 에러 무시 (프린트 완료 후 홈에서 처리)
      if (ref.read(printerServiceProvider).isLoading) {
        _pendingNetworkError = true;
        return;
      }

      _networkErrorHandled = true;
      _progressFrozen = true;
      _progressController.stop();

      if (!mounted) return;

      // 프린터 시작 전 네트워크 에러 → 자동 환불 후 에러 다이얼로그
      refund().then((_) {
        if (!mounted) return;
        checkCardSingleCardCount();
        DialogHelper.showKioskDialog(
          context,
          title: LocaleKeys.alert_title_network_error.tr(),
          contentText: LocaleKeys.alert_txt_print_network_error.tr(),
          confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
        ).then((_) {
          if (mounted) HomeRouteData().go(context);
        });
      });
    });

    // 실제 프린트 시작 시점 감지: 10% → 99% 애니메이션
    ref.listen(printerServiceProvider, (previous, next) {
      if (next.isLoading && !_progressCompleted && !_progressFrozen) {
        final pagePrintType = ref.read(pagePrintProvider);
        final isMetal = ref.read(kioskInfoServiceProvider)?.isMetal ?? false;
        final seconds = pagePrintType == PagePrintType.double ? (isMetal ? 68 : 60) : (isMetal ? 35 : 30);
        _progressController.animateTo(
          0.99,
          duration: Duration(seconds: seconds),
          curve: Curves.linear,
        );
      }
    });

    // listen 부분에서는 로딩 오버레이 처리를 제거
    ref.listen(printProcessScreenProviderProvider, (previous, next) async {
      if (!next.isLoading) {
        // 로딩이 아닐 때만 처리
        await next.when(
          error: (error, stack) async {
            if (_networkErrorHandled) return;

            // 오류 발생 시: 현재 진행률에서 멈춤 (요구사항)
            if (!_progressCompleted && !_progressFrozen) {
              _progressFrozen = true;
              _progressController.stop();
            }

            final cleanedError = error.toString().replaceFirst('Exception: ', '').trim();

            if (cleanedError.contains('Card feeder is empty')) {
              SlackLogService().sendBroadcastLogToSlackWithKey(ErrorKey.printerCardEmpty.key);
            } else if (cleanedError.contains('Failed to eject card')) {
              SlackLogService().sendBroadcastLogToSlackWithKey(ErrorKey.printerEjectFail.key);
            } else if (cleanedError.contains('Printer is not ready')) {
              SlackLogService().sendBroadcastLogToSlackWithKey(ErrorKey.printerReadyFail.key);
            } else {
              SlackLogService().sendBroadcastLogToSlackWithKey(ErrorKey.printerPrintFail.key);
            }

            final errorMessage = error.toString();

            // 슬랙에 에러 로그 전송
            errorLogging(error.toString(), stack);

            // 네트워크 오류인지 체크
            final isNetworkError = ref.read(networkStatusNotifierProvider.notifier).isNetworkError(error);

            if (isNetworkError) {
              checkCardSingleCardCount();
              await DialogHelper.showKioskDialog(
                context,
                title: LocaleKeys.alert_title_network_error.tr(),
                contentText: LocaleKeys.alert_txt_print_network_error.tr(),
                confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
              );
              HomeRouteData().go(context);
              return;
            }

            final result = await DialogHelper.showKioskDialog(
              context,
              title: LocaleKeys.alert_title_auto_refund_alert.tr(),
              contentText: LocaleKeys.alert_txt_auto_refund_alert.tr(),
              confirmButtonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
            );

            if (result) {
              // 에러 발생 시 환불 처리
              await refund();

              // 카드 단일 카드 수량 확인
              checkCardSingleCardCount();

              // 카드 공급기가 비어있는지 확인
              if (checkCardFeederIsEmpty(errorMessage)) {
                await DialogHelper.showPrintCardRefillDialog(
                  context,
                );
                if (result) {
                  HomeRouteData().go(context);
                }
              } else {
                final result = await DialogHelper.showPrintErrorDialog(
                  context,
                );
                if (result) {
                  HomeRouteData().go(context);
                }
              }
            }
          },
          loading: () => null,
          data: (_) async {
            if (!_progressCompleted) {
              _progressCompleted = true;
              await _progressController.animateTo(
                1.0,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
              );
            }

            checkCardSingleCardCount();

            ref.read(paymentResponseStateProvider.notifier).reset();

            await DialogHelper.showPrintCompleteDialog(
              context,
              onButtonPressed: () {
                HomeRouteData().go(context);
                if (_pendingNetworkError) {
                  final notifier = ref.read(networkStatusNotifierProvider.notifier);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    notifier.refresh();
                  });
                }
              },
            );
          },
        );
      }
    });

    final mainTextColor =
        ref.watch(kioskInfoServiceProvider)?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.sub03_txt_01.tr(),
              textAlign: TextAlign.center,
              style: isHwe
                  ? context.typography.vendingTitle2B.copyWith(color: mainTextColor)
                  : context.typography.kioskBody1B.copyWith(fontSize: 40.sp, color: mainTextColor),
            ),
            SizedBox(height: 23.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // 원하는 배경색
              ),
              child: Text(
                LocaleKeys.sub03_txt_02.tr(),
                textAlign: TextAlign.center,
                style: isHwe
                    ? context.typography.vendingBody1B
                        .copyWith(color: mainTextColor, fontSize: 36.sp, letterSpacing: -0.8)
                    : context.typography.kioskBody1B.copyWith(fontSize: 30.sp, color: mainTextColor),
              ),
            ),
            SizedBox(height: 60.h),
            randomAdImage == null
                ? Container(
                    width: 1080.w,
                    height: 400.h,
                    decoration: BoxDecoration(border: Border.all(color: Colors.transparent, width: 0.w)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: SizedBox(
                        child: Image.asset(
                          SnaptagImages.printLoading,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: 1080.w,
                    height: 400.h,
                    child: Image.file(
                      File(randomAdImage),
                      fit: BoxFit.contain,
                    ),
                  ),
            SizedBox(height: 40.h),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                final raw = _progressController.value;
                final percent = _progressCompleted ? 100 : (raw * 100).floor().clamp(0, 99);

                return _PrintProgressBar(
                  progress: _progressCompleted ? 1.0 : raw,
                  label: '$percent%',
                );
              },
            ),
            SizedBox(height: 16.h),
            Text(
              LocaleKeys.sub03_txt_03.tr(),
              textAlign: TextAlign.center,
              style: isHwe
                  ? context.typography.vendingBody2B.copyWith(color: mainTextColor, letterSpacing: 1.2)
                  : context.typography.kioskBody2B.copyWith(color: mainTextColor),
            ),
          ],
        ),
      ),
    );
  }

  bool checkCardFeederIsEmpty(String errorMessage) {
    return errorMessage.contains('Card feeder is empty');
  }

  void checkCardSingleCardCount() {
    final kioskInfo = ref.read(kioskInfoServiceProvider);
    final machineId = kioskInfo?.kioskMachineId ?? 0;

    if (ref.read(cardCountProvider).currentCount < 1) {
      ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
      SlackLogService().sendLogToSlack('*[MachineId : $machineId]*, change pagePrintType double');
    } else {
      ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
      SlackLogService().sendLogToSlack('*[MachineId : $machineId]*, change pagePrintType single');
    }
  }

  void errorLogging(String error, StackTrace stack) {
    logger.e('Print process error', error: error, stackTrace: stack);
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    SlackLogService().sendErrorLogToSlack('*[MachineId : $machineId]*, Print process error\nError: $error');
  }

  Future<void> refund() async {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    try {
      await ref.read(paymentServiceProvider.notifier).refund();
      if (ref.read(pagePrintProvider) == PagePrintType.single) await ref.read(cardCountProvider.notifier).increase();
    } catch (e) {
      SlackLogService().sendErrorLogToSlack('*[MachineId : $machineId]*, 환불 처리 중 오류 발생: $e');
      logger.e('환불 처리 중 오류 발생', error: e);
    }
  }

  /// 사용자 홈 디렉토리를 동기적으로 반환합니다.
  String? getUserDirectorySync() {
    return Platform.environment['USERPROFILE']; // Windows 전용
  }

  /// 최종: 랜덤 이미지 파일 경로 반환
  String? getRandomAdImagePath(WidgetRef ref) {
    final version = ref.read(versionStateProvider).currentVersion;
    final userDir = getUserDirectorySync();

    if (userDir == null) {
      print('❌ 사용자 디렉토리를 불러올 수 없습니다.');
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
        .where((f) => f.path.endsWith('.png') || f.path.endsWith('.jpg') || f.path.endsWith('.jpeg'))
        .toList();

    if (imageFiles.isEmpty) {
      print('❌ 이미지 파일이 없습니다.');
      return null;
    }

    final randomFile = imageFiles[Random().nextInt(imageFiles.length)];
    final fileName = randomFile.uri.pathSegments.last;

    return 'assets/adImages/$fileName';
  }

  String? getRandomAdImageFilePath(WidgetRef ref) {
    final kioskInfo = ref.read(kioskInfoServiceProvider);
    if (kioskInfo?.isHwe == true) {
      return 'assets/adImages/hanwha/printing_img.png';
    }

    final version = ref.read(versionStateProvider).currentVersion;
    final userDir = getUserDirectorySync();
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    if (userDir == null) {
      SlackLogService().sendLogToSlack('machineId: $machineId 배너를 불러오기 위한 사용자 디렉토리를 불러올 수 없습니다.');
      return null;
    }

    final adImageFolder = Directory((machineId == 2 || machineId == 3)
        ? '$userDir\\Snaptag\\$version\\assets\\adImages\\suwon'
        : (machineId == 1)
            ? '$userDir\\Snaptag\\$version\\assets\\adImages\\eland'
            : '$userDir\\Snaptag\\$version\\assets\\adImages\\ansan');

    if (!adImageFolder.existsSync()) {
      SlackLogService().sendLogToSlack('machineId: $machineId 배너를 불러오기 위한 이미지 폴더가 존재하지 않습니다.');
      print('❌ 이미지 폴더가 존재하지 않습니다: ${adImageFolder.path}');
      return null;
    }

    final imageFiles = adImageFolder
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png') || f.path.endsWith('.jpg') || f.path.endsWith('.jpeg'))
        .toList();

    if (imageFiles.isEmpty) {
      SlackLogService().sendLogToSlack('machineId: $machineId 배너를 불러오기 위한 이미지 폴더내부에 이미지가 존재하지 않습니다.');
      return null;
    }

    final randomFile = imageFiles[Random().nextInt(imageFiles.length)];
    return randomFile.path; // ⬅️ 여기서 전체 파일 경로 반환
  }
}

class _PrintProgressBar extends StatelessWidget {
  const _PrintProgressBar({
    required this.progress,
    required this.label,
  });

  /// 0.0 ~ 1.0
  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final kioskColors = context.theme.extension<KioskColors>()!;

    return SizedBox(
      width: 540.w,
      height: 35.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0x4DFFFFFF), // #FFFFFF4D
          ),
          child: Padding(
            padding: EdgeInsets.all(3.r),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: clamped,
                  heightFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            kioskColors.progressBarStartColor,
                            kioskColors.progressBarEndColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    label,
                    style: context.typography.kioskBody1B.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

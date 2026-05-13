import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/providers/version_notifier.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_response_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/notifiers/print_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/notifiers/print_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/screens/print_process_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';

class PrintProcessRoot extends ConsumerStatefulWidget {
  const PrintProcessRoot({super.key});

  @override
  ConsumerState<PrintProcessRoot> createState() => _PrintProcessRootState();
}

class _PrintProcessRootState extends ConsumerState<PrintProcessRoot> with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final String? _adImagePath;
  bool _progressCompleted = false;
  bool _progressFrozen = false;
  bool _networkErrorHandled = false;

  @override
  void initState() {
    super.initState();
    _adImagePath = _getRandomAdImageFilePath();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
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
    // 네트워크 끊김 즉시 감지: 프린트 미시작 시 홈으로 이동
    ref.listen<NetworkState>(networkStatusNotifierProvider, (previous, next) async {
      if (_networkErrorHandled) return;
      if (previous?.status == next.status) return;

      final isNetworkDown =
          next.status == NetworkStatus.disconnected || next.status == NetworkStatus.unstable;
      if (!isNetworkDown) return;
      if (_progressCompleted || _progressFrozen) return;
      if (ref.read(printerServiceProvider).isLoading) return;

      _networkErrorHandled = true;
      _progressFrozen = true;
      _progressController.stop();

      if (!mounted) return;

      await DialogHelper.showKioskDialog(
        context,
        title: LocaleKeys.alert_title_network_error.tr(),
        contentText: LocaleKeys.alert_txt_print_network_error.tr(),
        confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
      );
      if (context.mounted) HomeRouteData().go(context);
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

    // 프린트 완료/오류 처리
    ref.listen<PrintState>(printNotifierProvider, (previous, next) async {
      switch (next) {
        case PrintStateInitial():
          break;
        case PrintStateLoading():
          break;
        case PrintStateSuccess():
          if (!_progressCompleted) {
            setState(() => _progressCompleted = true);
            await _progressController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
            );
          }

          _checkCardSingleCardCount();
          ref.read(paymentResponseStateProvider.notifier).reset();

          final networkStatus = ref.read(networkStatusNotifierProvider).status;
          final isNetworkDown =
              networkStatus == NetworkStatus.disconnected || networkStatus == NetworkStatus.unstable;

          if (!context.mounted) return;
          await DialogHelper.showPrintCompleteDialog(context);

          if (isNetworkDown) {
            await Future.delayed(const Duration(milliseconds: 300));
            final rootContext = rootNavigatorKey.currentContext;
            if (rootContext != null && rootContext.mounted) {
              DialogHelper.showKioskDialog(
                rootContext,
                title: LocaleKeys.alert_title_network_error.tr(),
                contentText: LocaleKeys.alert_txt_print_network_error.tr(),
                confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
              );
            }
          }

        case PrintStateFailure(:final error, :final stackTrace):
          if (_networkErrorHandled) return;

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

          _errorLogging(error.toString(), stackTrace);

          final isNetworkError = ref.read(networkStatusNotifierProvider.notifier).isNetworkError(error);
          if (isNetworkError) {
            _checkCardSingleCardCount();
            if (!context.mounted) return;
            await DialogHelper.showKioskDialog(
              context,
              title: LocaleKeys.alert_title_network_error.tr(),
              contentText: LocaleKeys.alert_txt_print_network_error.tr(),
              confirmButtonText: LocaleKeys.alert_btn_print_failure.tr(),
            );
            if (context.mounted) HomeRouteData().go(context);
            return;
          }

          if (!context.mounted) return;
          final confirmed = await DialogHelper.showKioskDialog(
            context,
            title: LocaleKeys.alert_title_auto_refund_alert.tr(),
            contentText: LocaleKeys.alert_txt_auto_refund_alert.tr(),
            confirmButtonText: LocaleKeys.alert_btn_paymentcard_failure.tr(),
          );

          if (confirmed) {
            await _refund();
            _checkCardSingleCardCount();

            if (!context.mounted) return;
            if (_checkCardFeederIsEmpty(error.toString())) {
              await DialogHelper.showPrintCardRefillDialog(context);
              if (!context.mounted) return;
              HomeRouteData().go(context);
            } else {
              final shouldGoHome = await DialogHelper.showPrintErrorDialog(context);
              if (!context.mounted) return;
              if (shouldGoHome) HomeRouteData().go(context);
            }
          }
      }
    });

    return PrintProcessScreen(
      progressController: _progressController,
      progressCompleted: _progressCompleted,
      adImagePath: _adImagePath,
    );
  }

  bool _checkCardFeederIsEmpty(String errorMessage) {
    return errorMessage.contains('Card feeder is empty');
  }

  void _checkCardSingleCardCount() {
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

  void _errorLogging(String error, StackTrace stack) {
    logger.e('Print process error', error: error, stackTrace: stack);
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    SlackLogService().sendErrorLogToSlack('*[MachineId : $machineId]*, Print process error\nError: $error');
  }

  Future<void> _refund() async {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    try {
      await ref.read(paymentServiceProvider.notifier).refund();
      if (ref.read(pagePrintProvider) == PagePrintType.single) {
        await ref.read(cardCountProvider.notifier).increase();
      }
    } catch (e) {
      SlackLogService().sendErrorLogToSlack('*[MachineId : $machineId]*, 환불 처리 중 오류 발생: $e');
      logger.e('환불 처리 중 오류 발생', error: e);
    }
  }

  String? _getUserDirectorySync() {
    return Platform.environment['USERPROFILE'];
  }

  String? _getRandomAdImageFilePath() {
    final kioskInfo = ref.read(kioskInfoServiceProvider);
    if (kioskInfo?.isHwe == true) {
      return 'assets/adImages/hanwha/printing_img.png';
    }

    final version = ref.read(versionNotifierProvider).currentVersion;
    final userDir = _getUserDirectorySync();
    final machineId = kioskInfo?.kioskMachineId ?? 0;

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
    return randomFile.path;
  }
}

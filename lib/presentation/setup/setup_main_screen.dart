import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/local/id_writer.dart';
import 'package:flutter_snaptag_kiosk/core/providers/version_notifier.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_connect_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/alert_definition_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SetupMainScreen extends ConsumerStatefulWidget {
  const SetupMainScreen({super.key});

  @override
  ConsumerState<SetupMainScreen> createState() => _SetupMainScreenState();
}

class _SetupMainScreenState extends ConsumerState<SetupMainScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      final connected = await ref.read(printerServiceProvider.notifier).connectedPrinter();
      if (connected) {
        final settingCompleted = await ref.read(printerServiceProvider.notifier).checkSettingPrinter();
        if (mounted) {
          setState(() {
            ref.read(printerConnectProvider.notifier).update(
                  connected && settingCompleted
                      ? PrinterConnectState.connected
                      : settingCompleted
                          ? PrinterConnectState.connected
                          : PrinterConnectState.setupInComplete,
                );
          });
        } else {
          ref.read(printerConnectProvider.notifier).update(PrinterConnectState.disconnected);
        }
      } else {
        if (mounted) {
          setState(() {
            ref.read(printerConnectProvider.notifier).update(PrinterConnectState.disconnected);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onRunEventTap(BuildContext context) async {
    await SoundManager().playSound();

    final pagePrintType = ref.read(pagePrintProvider);
    if (pagePrintType == PagePrintType.none) {
      DialogHelper.showSetupDialog(
        context,
        title: '인쇄 타입을 선택해주세요.',
      );

      return;
    }

    if (pagePrintType == PagePrintType.single) {
      final cardCountState = ref.read(cardCountProvider);
      if (cardCountState.currentCount == 0) {
        if (!context.mounted) return;
        final confirmed = await DialogHelper.showSetupDialog(
          context,
          title: '양면 인쇄 전환',
          content: '단면 카드 수량이 0장으로 설정되었습니다.\n양면 인쇄로 전환하시겠습니까?',
          showCancelButton: true,
        );
        if (!confirmed) return;
        ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
      }
    }

    final isReady = await _validatePrinterReadyAndShowDialogs(context);

    if (!isReady) return;

    var kioskInfo = ref.read(kioskInfoServiceProvider);

    logger.d(
        'kioskInfo: $kioskInfo kioskMachineName: ${kioskInfo?.kioskMachineName} kioskMachineId: ${kioskInfo?.kioskMachineId}');

    // KioskMachineInfo가 없으면 다시 fetch
    if (kioskInfo == null) {
      await ref.read(kioskInfoServiceProvider.notifier).getKioskMachineInfo();
      kioskInfo = ref.read(kioskInfoServiceProvider);
    }

    if (kioskInfo == null || kioskInfo.kioskEventId == 0 || kioskInfo.kioskMachineId == 0) {
      if (!context.mounted) return;
      await DialogHelper.showSetupDialog(
        context,
        title: "이벤트를 실행하려면\n키오스크 기기번호를 입력해 주세요.",
      );
      return;
    }

    // 유료 결제인 경우만 KSCAT 리더기 점검
    if (kioskInfo.photoCardPrice > 0) {
      final isPaymentDeviceReady = await _checkPaymentDevice();
      if (!isPaymentDeviceReady) return;
    }

    await _writePhotocodeMeta();

    final confirmed = await DialogHelper.showSetupDialog(
      context,
      title: '이벤트를 실행합니다.',
      showCancelButton: true,
    );
    if (!confirmed) return;

    await _startEventFlow(context);
  }

  Future<bool> _validatePrinterReadyAndShowDialogs(BuildContext context) async {
    final connected = await ref.read(printerServiceProvider.notifier).connectedPrinter();
    final settingPrinter = await ref.read(printerServiceProvider.notifier).checkSettingPrinter();
    if (!connected) {
      await DialogHelper.showSetupDialog(
        context,
        title: '프린트가 준비중입니다.',
      );
      return false;
    }
    if (!settingPrinter) {
      await DialogHelper.showSetupDialog(
        context,
        title: '프린트 기기 상태를 확인해주세요.',
      );
      return false;
    }
    return true;
  }

  Future<void> _writePhotocodeMeta() async {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    final eventId = ref.read(kioskInfoServiceProvider)?.kioskEventId ?? 0;
    final cardCountState = ref.read(cardCountProvider);
    final cardCountInfo = "${cardCountState.initialCount} / ${cardCountState.currentCount}";

    final serviceNameMap = {
      "SUF": "수원FC",
      "SEF": "서울 이랜드 FC",
      "KEEFO": "성수 B'Day",
      "AGFC": "안산그리너스FC",
    };
    final eventType = ref.read(kioskInfoServiceProvider)?.eventType ?? '-';
    final serviceName = serviceNameMap[eventType] ?? '-';

    final versionState = ref.read(versionStateProvider);
    final currentVersion = versionState.currentVersion;

    await writePhotocodeId(
      machineId.toString(),
      eventId.toString(),
      cardCountInfo.toString(),
      serviceName.toString(),
      '$currentVersion',
    );
  }

  Future<void> _startEventFlow(BuildContext context) async {
    final versionState = ref.read(versionStateProvider);
    final currentVersion = versionState.currentVersion;
    final latestVersion = versionState.latestVersion;
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    final kioskEventId = ref.read(kioskInfoServiceProvider)?.kioskEventId ?? 0;
    final cardCountState = ref.read(cardCountProvider);

    try {
      await ref.read(printerServiceProvider.notifier).printerStateLog();
    } catch (e) {
      SlackLogService().sendErrorLogToSlack("Printer State Log: $e");
    }

    try {
      await ref.read(kioskRepositoryProvider).deleteEndMark(
            kioskEventId: kioskEventId,
            machineId: machineId,
            remainingSingleSidedCount: cardCountState.remainingSingleSidedCount,
          );
    } catch (e) {
      SlackLogService().sendErrorLogToSlack("Delete End Mark: $e");
    }

    SlackLogService()
        .sendLogToSlack('machineId:$machineId, currentVersion:$currentVersion, latestVersion:$latestVersion');

    HomeRouteData().go(context);

    SlackLogService().sendInspectionEndBroadcastLogToSlack(InfoKey.inspectionEnd.key);
  }

  Future<bool> _checkPaymentDevice() async {
    try {
      final response = await ref.read(paymentRepositoryProvider).check();
      SlackLogService().sendLogToSlack("Payment Device check: $response");

      return true;
    } catch (e) {
      SlackLogService().sendErrorLogToSlack("Payment Device check: $e");

      DialogHelper.showSetupDialog(
        context,
        title: '리더기 점검',
        content: '리더기 응답이 없습니다.\n연결 상태를 확인한 뒤 다시 시도해 주세요.',
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.read(alertDefinitionProvider);
    final machineId = ref.watch(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    final versionState = ref.watch(versionStateProvider);
    final cardCountState = ref.watch(cardCountProvider);
    final currentVersion = versionState.currentVersion;
    final isConnectedPrinter = ref.watch(printerConnectProvider) == PrinterConnectState.connected;
    final getInfoByKey = ref.watch(kioskInfoServiceProvider.notifier).getInfoByKey;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Pretendard',
            ),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        appBar: AppBar(
          centerTitle: false,
          title: SvgPicture.asset(
            SnaptagSvg.snaptagLogo,
            width: 160.w,
          ),
          actions: [
            InkWell(
              onTap: () async {
                final result = await DialogHelper.showSetupDialog(
                  context,
                  title: '프로그램을 종료합니다.',
                  showCancelButton: true,
                );
                if (result) {
                  try {
                    await ref.read(kioskRepositoryProvider).endKioskApplication(
                          kioskEventId: ref.read(kioskInfoServiceProvider)?.kioskEventId ?? 0,
                          machineId: ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0,
                          remainingSingleSidedCount: cardCountState.remainingSingleSidedCount,
                        );
                  } catch (e) {
                    SlackLogService().sendErrorLogToSlack("End Kiosk Application: $e");
                  }

                  // 종료
                  exit(0);
                }
              },
              child: SvgPicture.asset(
                SnaptagSvg.off,
                width: 44.w,
              ),
            ),
            SizedBox(width: 30.w),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(SnaptagImages.setupBackground),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  '관리자 모드',
                  style: context.typography.kioksNum1SB,
                ),
              ),
              SizedBox(height: 50.h),
              Center(
                child: Text(
                  getInfoByKey ? '*인쇄 모드 선택 후 이벤트를 실행 해주세요.' : '*인쇄 모드 선택 후 미리보기를 해주세요.',
                  style: context.typography.kioskBody1B.copyWith(color: Colors.red),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 390.w,
                    height: 120.h,
                    child: SetupSubCard(
                      label: '양면 인쇄',
                      mode: PagePrintType.double,
                      currentModeSelector: (ref) => ref.watch(pagePrintProvider),
                      activeAssetName: SnaptagSvg.printDoubleActive,
                      inactiveAssetName: SnaptagSvg.printDoubleInactive,
                      onTap: () async {
                        if (cardCountState.currentCount < 1) {
                          await SoundManager().playSound();
                          ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
                          if (machineId != 0) {
                            SlackLogService().sendBroadcastLogToSlackWithKey(InfoKey.cardPrintModeSwitchDuplex.key);
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 390.w,
                    height: 120.h,
                    child: SetupSubCard(
                      label: '단면 인쇄',
                      mode: PagePrintType.single,
                      currentModeSelector: (ref) => ref.watch(pagePrintProvider),
                      activeAssetName: SnaptagSvg.printSingleActive,
                      inactiveAssetName: SnaptagSvg.printSingleInactive,
                      onTap: () async {
                        await SoundManager().playSound();
                        ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 240.w,
                    height: 80.h,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '단면 카드 수량',
                        textAlign: TextAlign.center,
                        style: context.typography.kioskBody1B.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  //SizedBox(width: 40.w),
                  Container(
                    width: 520.w,
                    height: 80.h,
                    //padding: EdgeInsets.only(top: 50.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: ref.watch(pagePrintProvider) == PagePrintType.single ? Colors.black : Color(0xFFECEDEF),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      onTap: () async {
                        final isActive = ref.read(pagePrintProvider) == PagePrintType.single;
                        if (isActive) {
                          String? value = await DialogHelper.showKeypadDialog(context, mode: ModeType.card);

                          if (value == null || value.isEmpty) return; // 값이 없으면 종료
                          int cardNumber = int.parse(value);
                          ref.read(cardCountProvider.notifier).update(cardNumber);
                          if (cardNumber <= 0) {
                            ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
                          } else {
                            ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
                            if (machineId != 0) {
                              SlackLogService().sendBroadcastLogToSlackWithKey(InfoKey.cardPrintModeSwitchSingle.key);
                            }
                          }
                        } else {
                          print('click when pagePringType not single');
                        }
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          (cardCountState.currentCount).toString(),
                          textAlign: TextAlign.center,
                          style: ref.watch(pagePrintProvider) != PagePrintType.single
                              ? context.typography.kioskBody2B.copyWith(color: Color(0xFFECEDEF))
                              : context.typography.kioskBody2B.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 80.h,
                width: 760.w, //780
                child: Divider(
                  thickness: 1.h,
                  height: 0,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // getInfoByKey가 true면: 이벤트 미리보기 숨김, 이벤트 실행 -> 출력 내역
                  // getInfoByKey가 false면: 이벤트 미리보기 -> 출력 내역 -> 이벤트 실행
                  if (!getInfoByKey) ...[
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SizedBox(
                        width: 260.w,
                        height: 314.h,
                        child: SetupMainCard(
                          label: '이벤트\n미리보기',
                          assetName: SnaptagSvg.eventPreview,
                          onTap: () async {
                            await SoundManager().playSound();
                            if (cardCountState.currentCount < 1) {
                              ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
                            }
                            KioskInfoRouteData().go(context);
                          },
                        ),
                      ),
                    ),
                  ],
                  if (getInfoByKey) ...[
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SizedBox(
                        width: 260.w,
                        height: 314.h,
                        child: SetupMainCard(
                          label: '이벤트\n실행',
                          assetName: SnaptagSvg.eventRun,
                          onTap: () async {
                            await _onRunEventTap(context);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SizedBox(
                        width: 260.w,
                        height: 314.h,
                        child: SetupMainCard(
                          label: '출력 내역',
                          assetName: SnaptagSvg.payment,
                          onTap: () async {
                            await SoundManager().playSound();
                            PaymentHistoryRouteData().go(context);
                          },
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SizedBox(
                        width: 260.w,
                        height: 314.h,
                        child: SetupMainCard(
                          label: '출력 내역',
                          assetName: SnaptagSvg.payment,
                          onTap: () async {
                            await SoundManager().playSound();
                            PaymentHistoryRouteData().go(context);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SizedBox(
                        width: 260.w,
                        height: 314.h,
                        child: SetupMainCard(
                          label: '이벤트\n실행',
                          assetName: SnaptagSvg.eventRun,
                          onTap: () async {
                            await _onRunEventTap(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (F.appFlavor == Flavor.dev)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SizedBox(
                        width: 260.w,
                        height: 314.h,
                        child: SetupMainCard(
                            label: 'Unit Test',
                            onTap: () async {
                              await SoundManager().playSound();
                              UnitTestRouteData().go(context);
                            }),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SizedBox(
                        width: 260.w,
                        height: 314.h,
                        child: SetupMainCard(
                            label: 'Kiosk\nComponents',
                            onTap: () async {
                              await SoundManager().playSound();
                              KioskComponentsRouteData().go(context);
                            }),
                      ),
                    ),
                  ],
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: SizedBox(
                      width: 260.w,
                      height: 314.h,
                      child: SetupMainCard(
                        label: isConnectedPrinter ? '프린트\n사용가능' : '프린트\n준비중',
                        textColor: isConnectedPrinter ? Color(0xFF1C1C1C) : Color(0xFFD5D5D5),
                        assetName: isConnectedPrinter ? SnaptagSvg.printConnect : SnaptagSvg.printError,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: SizedBox(
                      width: 260.w,
                      height: 314.h,
                      child: SetupUpdateCard(
                        title: '현재 버전',
                        version: currentVersion,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: SizedBox(
                      width: 260.w,
                      height: 314.h,
                      child: SetupMainCard(
                        label: '서비스 점검',
                        assetName: SnaptagSvg.maintenance,
                        onTap: () async {
                          SlackLogService().sendBroadcastLogToSlackWithKey(InfoKey.serviceMaintenanceEnter.key);
                          await SoundManager().playSound();
                          MaintenanceRouteData().go(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              SizedBox(
                  width: 820.w, //780
                  height: 88.h,
                  child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}

class SetupMainCard extends StatelessWidget {
  final String label;
  final String? assetName;
  final void Function()? onTap;
  final Color? textColor;

  const SetupMainCard({super.key, required this.label, this.assetName, this.onTap, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Color(0xFFE6E8EB),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: assetName != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    SvgPicture.asset(
                      assetName ?? '',
                      width: 260.w,
                      height: 200.w,
                      fit: BoxFit.cover,
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(bottom: 22.h),
                      child: SizedBox(
                        width: 260.w,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor ?? Color(0xFF1C1C1C),
                            letterSpacing: -0.1,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                )
              : Center(
                  child: SizedBox(
                    width: 260.w,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor ?? Color(0xFF1C1C1C),
                        letterSpacing: -0.1,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class SetupSubCard<T> extends ConsumerWidget {
  final String label;
  final T mode;
  final T Function(WidgetRef ref) currentModeSelector;
  final String activeAssetName;
  final String inactiveAssetName;
  final void Function()? onTap;
  const SetupSubCard({
    super.key,
    required this.label,
    required this.mode,
    required this.currentModeSelector,
    required this.activeAssetName,
    required this.inactiveAssetName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final T current = currentModeSelector(ref);
    final bool isActive = current == mode;
    print("current Type: $current");
    print("isActive : $isActive");
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        width: 400.w,
        height: 120.h,
        //padding: EdgeInsets.only(top: 50.w),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          border: Border.all(
            color: Color(0xFFE6E8EB),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 72.5.w), //60
              SvgPicture.asset(
                isActive ? activeAssetName : inactiveAssetName,
                width: 80.w,
                height: 80.w,
              ),
              SizedBox(width: 23.w),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: isActive
                      ? context.typography.kioskInput2B.copyWith(color: Colors.white)
                      : context.typography.kioskInput2B.copyWith(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SetupUpdateCard extends StatelessWidget {
  final String title;
  final String version;

  const SetupUpdateCard({
    super.key,
    required this.title,
    required this.version,
    String? buttonName,
    bool? isActive,
    VoidCallback? onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Color(0xFFE6E8EB),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Container(
        width: 260.w,
        height: 342.h,
        padding: EdgeInsets.only(top: 63.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40.w),
            Text(
              title,
              style: context.typography.kioskBody2B.copyWith(
                color: Color(0xFF999999),
              ),
            ),
            SizedBox(height: 12.w),
            Text(version, style: context.typography.kioskNum2B),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class UpdateNoticeBanner extends StatelessWidget {
  final String latestVersion;

  const UpdateNoticeBanner({
    super.key,
    required this.latestVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: const Color(0xFF444444),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
            children: [
              const TextSpan(text: '최신 버전 '),
              TextSpan(
                text: latestVersion,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '이 출시되었습니다.\n원활한 이용을 위해 업데이트를 진행해주세요',
                style: TextStyle(color: Color.fromARGB(204, 255, 255, 255)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

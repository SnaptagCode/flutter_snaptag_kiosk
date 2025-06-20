import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/utils/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_snaptag_kiosk/core/providers/version_notifier.dart';
import 'package:flutter_snaptag_kiosk/core/utils/launcher_service.dart';

class SetupMainScreen extends ConsumerWidget {
  const SetupMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionState = ref.watch(versionStateProvider);
    final cardCountState = ref.watch(cardCountProvider);
    final currentVersion = versionState.currentVersion;
    final latestVersion = versionState.latestVersion;
    final isUpdateAvailable = currentVersion != latestVersion;
    //final isUpdateAvailable = false;

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
                );
                if (result) {
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
                  '*인쇄 모드를 선택 후 미리보기를 해주세요.',
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
                        await SoundManager().playSound();
                        ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
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
                        style: context.typography.kioskBody1B,
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
                          final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
                          ref.read(cardCountProvider.notifier).update(cardNumber);
                          if (cardNumber <= 0) {
                            ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
                          } else {
                            ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
                          }
                        } else {
                          print('click when pagePringType not single');
                        }
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          (cardCountState).toString(),
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
                  SizedBox(
                    width: 260.w,
                    height: 342.h,
                    child: SetupMainCard(
                      label: '이벤트\n미리보기',
                      assetName: SnaptagSvg.eventPreview,
                      onTap: () async {
                        if (ref.read(pagePrintProvider) != PagePrintType.none) {
                          await SoundManager().playSound();
                          if (cardCountState < 1) {
                            ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
                          }
                          KioskInfoRouteData().go(context);
                        } else {
                          print('이벤트를 선택해주세요');
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 260.w,
                    height: 342.h,
                    child: SetupMainCard(
                      label: '출력 내역',
                      assetName: SnaptagSvg.payment,
                      onTap: () async {
                        await SoundManager().playSound();

                        PaymentHistoryRouteData().go(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 260.w,
                    height: 342.h,
                    child: SetupMainCard(
                      label: '이벤트\n실행',
                      assetName: SnaptagSvg.eventRun,
                      onTap: () async {
                        await SoundManager().playSound();

                        final connected = await ref.read(printerServiceProvider.notifier).isConnected();
                        final settingPrinter = ref.read(printerServiceProvider.notifier).settingPrinter();

                        if (!connected) {
                          final result = await DialogHelper.showSetupDialog(
                            context,
                            title: '프린터 연결 안됨',
                          );

                          return;
                        }

                        if (!settingPrinter) {
                          final result = await DialogHelper.showSetupDialog(
                            context,
                            title: '카드 공급기를 확인해주세요.',
                          );

                          return;
                        }

                        final result = await DialogHelper.showSetupDialog(
                          context,
                          title: '이벤트를 실행합니다.',
                        );
                        if (result) {
                          final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
                          SlackLogService().sendLogToSlack(
                              'machineId:$machineId, currentVersion:$currentVersion, latestVersion:$latestVersion');
                          if (cardCountState < 1) {
                            ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
                            SlackLogService().sendLogToSlack(
                                'machineId: $machineId, singleCard: $cardCountState, set pagePrintType double');
                          } else {
                            ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
                            SlackLogService().sendLogToSlack(
                                'machineId: $machineId, singleCard: $cardCountState, set pagePrintType single');
                          }
                          PhotoCardUploadRouteData().go(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (F.appFlavor == Flavor.dev)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 260.w,
                      height: 342.h,
                      child: SetupMainCard(
                          label: 'Unit Test',
                          onTap: () async {
                            await SoundManager().playSound();

                            UnitTestRouteData().go(context);
                          }),
                    ),
                    SizedBox(
                      width: 260.w,
                      height: 342.h,
                      child: SetupMainCard(
                          label: 'Kiosk\nComponents',
                          onTap: () async {
                            await SoundManager().playSound();

                            KioskComponentsRouteData().go(context);
                          }),
                    ),
                  ],
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 260.w,
                    height: 342.h,
                    child: SetupMainCard(
                      label: '서비스 점검',
                      assetName: SnaptagSvg.maintenance,
                      onTap: () async {
                        await SoundManager().playSound();

                        MaintenanceRouteData().go(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 260.w,
                    height: 342.h,
                    child: SetupUpdateCard(
                      title: '현재 버전',
                      //version: currentVersion,
                      version: "v2.4.7",
                      buttonName: '업데이트',
                      isActive: isUpdateAvailable,
                      onUpdatePressed: () async {
                        final result = await DialogHelper.showSetupTwoDialog(
                          context,
                          title: '업데이트 하시겠습니까?',
                          contentText: '업데이트 시 앱이 재시작 됩니다.',
                        );
                        if (result) {
                          try {
                            final launcherPath = await LauncherPathUtil.getLauncherPath();
                            await ForceUpdateWriter.writeForceUpdateTrue();
                            print("Process.start");
                            await Process.start(
                              launcherPath,
                              ['f'],
                              runInShell: true,
                              mode: ProcessStartMode.detached,
                            );
                            print("Process.start(launcherPath, ['f'])");
                            exit(0);
                          } catch (e) {
                            print("런처 실행 실패: $e");
                          }
                        } else {}
                      },
                    ),
                  ),
                  SizedBox(
                    width: 260.w,
                    height: 342.h,
                  ),
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              SizedBox(
                  width: 820.w, //780
                  height: 88.h,
                  child:
                      isUpdateAvailable ? UpdateNoticeBanner(latestVersion: versionState.latestVersion) : SizedBox()),
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
  const SetupMainCard({
    super.key,
    required this.label,
    this.assetName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        width: 260.w,
        height: 342.h,
        padding: EdgeInsets.only(top: 50.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color(0xFFE6E8EB),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (assetName != null) ...[
                SvgPicture.asset(
                  assetName ?? '',
                  width: 100.w,
                  height: 100.w,
                )
              ],
              SizedBox(height: 50.w),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.typography.kioskInput2B,
                ),
              ),
            ],
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
  final String buttonName;
  final bool isActive;
  final VoidCallback? onUpdatePressed;

  const SetupUpdateCard({
    super.key,
    required this.title,
    required this.version,
    required this.buttonName,
    required this.isActive,
    this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        width: 260.w,
        height: 342.h,
        padding: EdgeInsets.only(top: 63.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color(0xFFE6E8EB),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
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
            SizedBox(
              width: 216.w,
              height: 46.h,
              child: ElevatedButton(
                onPressed: isActive ? onUpdatePressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Color(0xFF316FFF) : Color(0xFFD5D5D5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '$buttonName',
                  style: context.typography.kioskBody2B.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.w),
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
                text: '$latestVersion',
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

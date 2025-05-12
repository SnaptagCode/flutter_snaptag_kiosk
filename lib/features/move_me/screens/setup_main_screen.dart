import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/utils/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SetupMainScreen extends ConsumerWidget {
  const SetupMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                      final result = await DialogHelper.showSetupDialog(
                        context,
                        title: '이벤트를 실행합니다.',
                      );
                      if (result) {
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
                ),
                SizedBox(
                  width: 260.w,
                  height: 342.h,
                ),
              ],
            ),
          ],
        ),
      ),
    ),);
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
          color: isActive? Colors.black : Colors.white,
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
                  isActive? activeAssetName : inactiveAssetName,
                  width: 80.w,
                  height: 80.w,
                ),
              SizedBox(width: 23.w),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: isActive? context.typography.kioskInput2B.copyWith(color: Colors.white) : context.typography.kioskInput2B.copyWith(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

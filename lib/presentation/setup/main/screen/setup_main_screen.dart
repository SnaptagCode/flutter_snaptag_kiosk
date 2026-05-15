import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:flutter_snaptag_kiosk/flavors.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifier/setup_main_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/screen/setup_main_screen_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';

class SetupMainScreen extends StatelessWidget {
  const SetupMainScreen({super.key, required this.state, required this.onAction});

  final SetupMainScreenState state;
  final void Function(SetupMainAction) onAction;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Pretendard'),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          centerTitle: false,
          title: SvgPicture.asset(SnaptagSvg.snaptagLogo, width: 160.w),
          actions: [
            InkWell(
              onTap: () async {
                await SoundManager().playSound();
                onAction(const SetupMainAction.requestExitApp());
              },
              child: SvgPicture.asset(SnaptagSvg.off, width: 44.w),
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
                child: Text('관리자 모드', style: context.typography.kioksNum1SB),
              ),
              SizedBox(height: 50.h),
              Center(
                child: Text(
                  state.hasKioskInfo ? '*인쇄 모드 선택 후 이벤트를 실행 해주세요.' : '*인쇄 모드 선택 후 미리보기를 해주세요.',
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
                      currentMode: state.pagePrintType,
                      activeAssetName: SnaptagSvg.printDoubleActive,
                      inactiveAssetName: SnaptagSvg.printDoubleInactive,
                      onTap: () async {
                        if (state.cardCount >= 1) return;
                        await SoundManager().playSound();
                        onAction(const SetupMainAction.selectPrintType(PagePrintType.double));
                      },
                    ),
                  ),
                  SizedBox(
                    width: 390.w,
                    height: 120.h,
                    child: SetupSubCard(
                      label: '단면 인쇄',
                      mode: PagePrintType.single,
                      currentMode: state.pagePrintType,
                      activeAssetName: SnaptagSvg.printSingleActive,
                      inactiveAssetName: SnaptagSvg.printSingleInactive,
                      onTap: () async {
                        await SoundManager().playSound();
                        onAction(const SetupMainAction.selectPrintType(PagePrintType.single));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                  Container(
                    width: 520.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: state.pagePrintType == PagePrintType.single
                            ? Colors.black
                            : const Color(0xFFECEDEF),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      onTap: () async {
                        if (state.pagePrintType != PagePrintType.single) return;
                        final value = await DialogHelper.showKeypadDialog(context, mode: ModeType.card);
                        if (value == null || value.isEmpty) return;
                        onAction(SetupMainAction.updateCardCount(int.parse(value)));
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          state.cardCount.toString(),
                          textAlign: TextAlign.center,
                          style: state.pagePrintType != PagePrintType.single
                              ? context.typography.kioskBody2B.copyWith(color: const Color(0xFFECEDEF))
                              : context.typography.kioskBody2B.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 80.h,
                width: 760.w,
                child: Divider(thickness: 1.h, height: 0),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!state.hasKioskInfo)
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
                            onAction(const SetupMainAction.requestEventPreview());
                          },
                        ),
                      ),
                    ),
                  if (state.hasKioskInfo) ...[
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SizedBox(
                        width: 260.w,
                        height: 314.h,
                        child: SetupMainCard(
                          label: '이벤트\n실행',
                          assetName: SnaptagSvg.eventRun,
                          onTap: () async {
                            await SoundManager().playSound();
                            onAction(const SetupMainAction.requestEventStart());
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
                            onAction(const SetupMainAction.requestPaymentHistory());
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
                            onAction(const SetupMainAction.requestPaymentHistory());
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
                            await SoundManager().playSound();
                            onAction(const SetupMainAction.requestEventStart());
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
                            onAction(const SetupMainAction.requestUnitTest());
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
                          label: 'Kiosk\nComponents',
                          onTap: () async {
                            await SoundManager().playSound();
                            onAction(const SetupMainAction.requestKioskComponents());
                          },
                        ),
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
                        label: state.isPrinterConnected ? '프린트\n사용가능' : '프린트\n준비중',
                        textColor: state.isPrinterConnected ? const Color(0xFF1C1C1C) : const Color(0xFFD5D5D5),
                        assetName: state.isPrinterConnected ? SnaptagSvg.printConnect : SnaptagSvg.printError,
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
                        version: state.currentVersion,
                        buttonName: '업데이트',
                        isActive: state.isUpdateAvailable,
                        onUpdatePressed: () async {
                          await SoundManager().playSound();
                          onAction(const SetupMainAction.requestUpdate());
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
                        label: '서비스 점검',
                        assetName: SnaptagSvg.maintenance,
                        onTap: () async {
                          await SoundManager().playSound();
                          onAction(const SetupMainAction.requestMaintenance());
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: 820.w,
                height: 88.h,
                child: state.isUpdateAvailable
                    ? UpdateNoticeBanner(latestVersion: state.latestVersion)
                    : const SizedBox(),
              ),
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
        side: const BorderSide(color: Color(0xFFE6E8EB), width: 2),
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
                    SvgPicture.asset(assetName ?? '', width: 260.w, height: 200.w, fit: BoxFit.cover),
                    const Spacer(),
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
                            color: textColor ?? const Color(0xFF1C1C1C),
                            letterSpacing: -0.1,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
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
                        color: textColor ?? const Color(0xFF1C1C1C),
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

class SetupSubCard extends StatelessWidget {
  final String label;
  final PagePrintType mode;
  final PagePrintType currentMode;
  final String activeAssetName;
  final String inactiveAssetName;
  final void Function()? onTap;

  const SetupSubCard({
    super.key,
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.activeAssetName,
    required this.inactiveAssetName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentMode == mode;
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        width: 400.w,
        height: 120.h,
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          border: Border.all(color: const Color(0xFFE6E8EB)),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 72.5.w),
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
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE6E8EB), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Container(
        width: 260.w,
        height: 342.h,
        padding: EdgeInsets.only(top: 63.h),
        child: Column(
          children: [
            SizedBox(height: 40.w),
            Text(title, style: context.typography.kioskBody2B.copyWith(color: const Color(0xFF999999))),
            SizedBox(height: 12.w),
            Text(version, style: context.typography.kioskNum2B),
            const Spacer(),
            SizedBox(
              width: 216.w,
              height: 46.h,
              child: ElevatedButton(
                onPressed: isActive ? onUpdatePressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? const Color(0xFF316FFF) : const Color(0xFFD5D5D5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  buttonName,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                    height: 1.0,
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

  const UpdateNoticeBanner({super.key, required this.latestVersion});

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
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 20.sp),
            children: [
              const TextSpan(text: '최신 버전 '),
              TextSpan(text: latestVersion, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(
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

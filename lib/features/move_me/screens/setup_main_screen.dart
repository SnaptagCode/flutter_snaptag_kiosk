import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SetupMainScreen extends ConsumerWidget {
  const SetupMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // F2F2F2
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(.5),
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
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              left: 712.w,
              top: 1411.h - AppBar().preferredSize.height,
              child: SvgPicture.asset(
                SnaptagSvg.snaptagIcon,
                width: 476.w,
                height: 569.h,
              ),
            ),
            Column(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _navigatorCard(
                      context,
                      label: '이벤트\n미리보기',
                      assetName: SnaptagSvg.eventPreview,
                      onTap: () => KioskInfoRouteData().go(context),
                    ),
                    _navigatorCard(
                      context,
                      label: '출력 내역',
                      assetName: SnaptagSvg.payment,
                      onTap: () => PaymentHistoryRouteData().go(context),
                    ),
                    _navigatorCard(
                      context,
                      label: '이벤트\n실행',
                      assetName: SnaptagSvg.eventRun,
                      onTap: () async {
                        final result = await DialogHelper.showSetupDialog(
                          context,
                          title: '이벤트를 실행합니다.',
                        );
                        if (result) {
                          PhotoCardUploadRouteData().go(context);
                        }
                      },
                    ),
                  ],
                ),
                if (F.appFlavor == Flavor.dev)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _navigatorCard(context, label: 'Debug', onTap: () => UnitTestRouteData().go(context)),
                      _navigatorCard(context, label: 'Material', onTap: () => MaterialRouteData().go(context)),
                      _navigatorCard(context,
                          label: 'Kiosk Components', onTap: () => KioskComponentsRouteData().go(context)),
                    ],
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _navigatorCard(BuildContext context, {required String label, String? assetName, void Function()? onTap}) {
    return SizedBox(
      width: 260.w,
      height: 342.h,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            //#E6E8EB
            color: Color(0xFFE6E8EB),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(top: 50.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (assetName != null) ...[
                  SvgPicture.asset(
                    assetName,
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
      ),
    );
  }
}

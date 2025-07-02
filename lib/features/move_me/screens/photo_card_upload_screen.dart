import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/utils/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_warning_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PhotoCardUploadScreen extends ConsumerWidget {
  const PhotoCardUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    
    // 위젯이 렌더링된 후에 리본/필름 경고 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ribbonWarningProvider.notifier).checkAndSendWarnings(ref);
    });

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        //FontThemed(child: Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.main_txt_01_01.tr(),
            style: context.typography.kioskBody1B,
          ),
          SizedBox(height: 12.h),
          Text(
            LocaleKeys.main_txt_01_02.tr(),
            style: context.typography.kioskBody1B,
          ),
          SizedBox(height: 12.h),
          Text(
            LocaleKeys.main_txt_01_03.tr(),
            style: context.typography.kioskBody2B
                .copyWith(color: Color(int.parse(kiosk?.couponTextColor.replaceFirst('#', '0xff') ?? '0xffffff'))),
          ),
          SizedBox(height: 30.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: QrImageView(
              data:
                  '${F.qrCodePrefix}/${context.locale.languageCode}/${ref.read(kioskInfoServiceProvider)?.kioskEventId} ',
              size: 330.r,
              padding: EdgeInsets.all(20.r),
              version: QrVersions.auto,
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            LocaleKeys.main_txt_02.tr(),
            style: context.typography.kioskBody2B,
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            style: context.mainLargeButtonStyle,
            child: Text(
              LocaleKeys.main_btn_txt.tr(),
              /*style: context.locale.languageCode == 'ja'?
            TextStyle(fontFamily: 'Cafe24Ssurround2') :
            TextStyle(fontFamily: 'MPLUSRounded'),*/
            ),
            onPressed: () async {
              await SoundManager().playSound();

              ;
              CodeVerificationRouteData().go(context);
            },
          ),
        ],
        //),
      ),
    );
  }
}

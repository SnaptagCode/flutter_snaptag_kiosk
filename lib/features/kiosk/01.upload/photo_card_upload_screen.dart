import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PhotoCardUploadScreen extends StatelessWidget {
  const PhotoCardUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.main_txt_01_01.tr(),
          style: context.typography.kioskBody1B,
        ),
        Text(
          LocaleKeys.main_txt_01_02.tr(),
          style: context.typography.kioskBody1B,
        ),
        Text(
          LocaleKeys.main_txt_01_03.tr(),
          style: context.typography.kioskBody1B,
        ),
        QrImageView(
          data: 'https://photocard-kiosk-qr.snaptag.co.kr',
          size: 330.r,
          padding: EdgeInsets.all(20.r),
          version: QrVersions.auto,
        ),
        Text(
          LocaleKeys.main_txt_02.tr(),
          style: context.typography.kioskBody2B,
        ),
        ElevatedButton(
          style: context.mainLargeButtonStyle,
          child: Text(
            LocaleKeys.main_btn_txt.tr(),
          ),
          onPressed: () async {
            CodeVerificationRouteData().go(context);
          },
        ),
      ],
    );
  }
}

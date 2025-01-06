import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/flavors.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PhotoCardUploadScreen extends ConsumerWidget {
  const PhotoCardUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
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
          style: context.typography.kioskBody2B,
        ),
        SizedBox(height: 30.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: QrImageView(
            data:
                '${F.qrCodePrefix}/${context.locale.languageCode}/${ref.watch(yamlStorageServiceProvider).settings.kioskEventId} ',
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
          ),
          onPressed: () async {
            CodeVerificationRouteData().go(context);
          },
        ),
      ],
    );
  }
}

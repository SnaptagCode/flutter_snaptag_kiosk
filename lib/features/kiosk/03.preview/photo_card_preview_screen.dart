// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class PhotoCardPreviewScreen extends ConsumerStatefulWidget {
  const PhotoCardPreviewScreen({
    super.key,
    required this.extra,
  });
  final BackPhotoCardResponse extra;
  @override
  ConsumerState<PhotoCardPreviewScreen> createState() => _PhotoCardPreviewScreenState();
}

class _PhotoCardPreviewScreenState extends ConsumerState<PhotoCardPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.sub02_txt_01.tr(),
            textAlign: TextAlign.center,
            style: context.typography.kioskBody1B,
          ),
          SizedBox(height: 30.h),
          GradientContainer(
            content: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                widget.extra.formattedBackPhotoCardUrl,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PriceBox(),
              SizedBox(width: 20.w),
              ElevatedButton(
                style: context.paymentButtonStyle,
                onPressed: () {
                  ref.read(photoCardPreviewProvider.notifier).payment();
                },
                child: Text(
                  LocaleKeys.sub02_btn_pay.tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

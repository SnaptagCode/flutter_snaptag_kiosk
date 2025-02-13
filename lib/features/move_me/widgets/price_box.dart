import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

///
/// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=931-13839&m=dev)
/// - `priceValue` : #000000
/// - `currency` : #000000
///
class PriceBox extends ConsumerWidget {
  const PriceBox({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final photoCardPrice = ref.read(kioskInfoServiceProvider.notifier).settings.photoCardPrice;
    String priceValue = NumberFormat.currency(locale: 'ko_KR', symbol: '').format(photoCardPrice);

    String currency = context.locale.languageCode == 'ko' ? '원' : 'KRW';

    return Container(
      width: 360.w,
      height: 78.h,
      decoration: context.priceBoxDecoration,
      padding: EdgeInsets.all(8.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            priceValue,
            style: context.typography.kioskInput2B.copyWith(color: Colors.black),
          ),
          SizedBox(width: 12.w),
          Text(
            currency,
            style: context.typography.kioskInput3B.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

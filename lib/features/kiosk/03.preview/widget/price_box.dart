import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class PriceBox extends ConsumerWidget {
  const PriceBox({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final photoCardPrice = ref.watch(yamlStorageServiceProvider).settings.photoCardPrice;
    String priceValue = NumberFormat.currency(locale: 'ko_KR', symbol: '').format(photoCardPrice);

    String currency = context.locale.languageCode == 'ko' ? '원' : 'KRW';

    return Container(
      width: 360.w,
      height: 78.h,
      decoration: context.priceBoxDecoration,
      padding: EdgeInsets.all(8.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // 텍스트를 오른쪽 정렬
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            priceValue,
            style: context.typography.kioskInput2B,
          ),
          SizedBox(width: 12.w), // 숫자와 단위 사이 간격
          Text(
            currency,
            style: context.typography.kioskInput3B,
          ),
        ],
      ),
    );
  }
}

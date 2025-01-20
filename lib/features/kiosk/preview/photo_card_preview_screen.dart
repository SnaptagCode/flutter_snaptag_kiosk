// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
    // 결제 상태 감시
    ref.listen<AsyncValue<void>>(
      photoCardPreviewProvider,
      (previous, next) {
        // 로딩 상태 처리
        if (next.isLoading) {
          context.loaderOverlay.show();
          return;
        }

        // 로딩 오버레이 숨기기
        if (context.loaderOverlay.visible) {
          context.loaderOverlay.hide();
        }

        // 에러/성공 처리
        next.whenOrNull(
          error: (error, stack) async {
            await DialogHelper.showPurchaseFailedDialog(context);
            logger.e('Payment error: $error stacktrace $stack');
          },
          data: (_) {
            // 결제 성공 처리
            PrintProcessRouteData().go(context);
          },
        );
      },
    );

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
              const PriceBox(),
              SizedBox(width: 20.w),
              ElevatedButton(
                style: context.paymentButtonStyle,
                onPressed: () => ref.read(photoCardPreviewProvider.notifier).payment(),
                child: Text(LocaleKeys.sub02_btn_pay.tr()),
              ),
            ],
          ),
          if (F.appFlavor == Flavor.dev) ...[
            SizedBox(height: 20.h),
            _buildTestButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => ref.read(photoCardPreviewProvider.notifier).simulateSuccess(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Success'),
        ),
        SizedBox(width: 10.w),
        ElevatedButton(
          onPressed: () => ref.read(photoCardPreviewProvider.notifier).simulateError(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Error'),
        ),
      ],
    );
  }
}

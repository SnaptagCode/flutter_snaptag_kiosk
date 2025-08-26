// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/utils/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/providers/payment_failure_provider.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PhotoCardPreviewScreen extends ConsumerStatefulWidget {
  const PhotoCardPreviewScreen({
    super.key,
  });
  @override
  ConsumerState<PhotoCardPreviewScreen> createState() => _PhotoCardPreviewScreenState();
}

class _PhotoCardPreviewScreenState extends ConsumerState<PhotoCardPreviewScreen> {
  Future<void> _handlePaymentError(Object error, StackTrace stack) async {
    logger.e('Payment error occurred', error: error, stackTrace: stack);
    await DialogHelper.showPurchaseFailedDialog(
      context,
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      photoCardPreviewScreenProviderProvider,
      (previous, next) async {
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
        await next.when(
          error: (_, __) async {
            await DialogHelper.showPurchaseFailedDialog(
              context,
            );
            return;
          },
          loading: () => null,
          data: (_) async {
            final order = ref.watch(updateOrderInfoProvider)?.status;
            if (order == OrderStatus.completed) {
              PrintProcessRouteData().go(context);
            } else {
              await DialogHelper.showPurchaseFailedDialog(
                context,
              );
            }
          },
        );
      },
    );
    final kiosk = ref.watch(kioskInfoServiceProvider);

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Center(
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
                child: ref.watch(verifyPhotoCardProvider).when(
                  data: (data) {
                    return Image.network(
                      data?.formattedBackPhotoCardUrl ?? '',
                    );
                  },
                  loading: () {
                    return const CircularProgressIndicator();
                  },
                  error: (error, stack) {
                    return GeneralErrorWidget(
                      exception: error as Exception,
                      onRetry: () => ref.refresh(verifyPhotoCardProvider),
                    );
                  },
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
                  onPressed: () async {
                    await SoundManager().playSound();

                    if (context.mounted) {
                      final result = await DialogHelper.showPaymentDiscriptionDialog(context);

                      if (result) {
                        await ref.read(photoCardPreviewScreenProviderProvider.notifier).payment();
                        final isPaymentFailed = ref.read(paymentFailureProvider);
                        if (isPaymentFailed) {
                          ref.read(paymentFailureProvider.notifier).reset();
                          if (context.mounted) {
                            DialogHelper.showPaymentCardFailedDialog(
                              context,
                            );
                            PhotoCardUploadRouteData().go(context);
                          }
                        }
                      }
                    }
                  },
                  child: Text(LocaleKeys.sub02_btn_pay.tr()),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Text(
              LocaleKeys.sub03_txt_03.tr(),
              style: context.typography.kioskBody2B.copyWith(
                color: Color(int.parse(kiosk?.couponTextColor.replaceFirst('#', '0xff') ?? '0xffffff')),
                //fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final selection = ref.watch(backPhotoTypeProvider);
    final isFixed = selection?.type == BackPhotoType.fixed;
    final selectedIndex = selection?.fixedIndex;

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
            if (isFixed)
              Container(
                width: 1080.w,
                height: 360.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border.all(color: Colors.transparent, width: 0.w)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 첫 번째 고정 뒷면 이미지 선택 (인덱스 0)
                        ref.read(backPhotoTypeProvider.notifier).selectFixed(0);
                      },
                      child: Opacity(
                        opacity: selectedIndex == null ? 1.0 : (selectedIndex == 0 ? 1.0 : 0.5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(kiosk?.nominatedBackPhotoCardList[0].originUrl ?? ''),
                        ),
                      ),
                    ),
                    SizedBox(width: 150.w),
                    GestureDetector(
                      onTap: () {
                        // 두 번째 고정 뒷면 이미지 선택 (인덱스 1)
                        ref.read(backPhotoTypeProvider.notifier).selectFixed(1);
                      },
                      child: Opacity(
                        opacity: selectedIndex == null ? 1.0 : (selectedIndex == 1 ? 1.0 : 0.5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(kiosk?.nominatedBackPhotoCardList[1].originUrl ?? ''),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
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

                    // 선택된 뒷면 이미지 타입 확인
                    final selection = ref.read(backPhotoTypeProvider);

                    if (selection?.type == BackPhotoType.fixed && selection?.fixedIndex != null) {
                      // 고정 뒷면 이미지 결제 처리
                      final kiosk = ref.read(kioskInfoServiceProvider);
                      final selectedIndex = selection!.fixedIndex!;

                      if (kiosk != null && selectedIndex < kiosk.nominatedBackPhotoCardList.length) {
                        final selectedCard = kiosk.nominatedBackPhotoCardList[selectedIndex];
                        final response = await ref.read(kioskRepositoryProvider).getBackPhotoCardByQr(
                              kiosk.kioskEventId,
                              selectedCard.id,
                            );

                        ref.read(verifyPhotoCardProvider.notifier).updateState(BackPhotoCardResponse(
                            kioskEventId: kiosk.kioskEventId,
                            backPhotoCardId: selectedCard.id,
                            backPhotoCardOriginUrl: selectedCard.originUrl,
                            photoAuthNumber: response.photoAuthNumber,
                            formattedBackPhotoCardUrl: response.formattedBackPhotoCardUrl));
                      }
                    }

                    await ref.read(photoCardPreviewScreenProviderProvider.notifier).payment();
                    final isPaymentFailed = ref.read(paymentFailureProvider);
                    if (isPaymentFailed) {
                      ref.read(paymentFailureProvider.notifier).reset();
                      DialogHelper.showPaymentCardFailedDialog(
                        context,
                      );
                      PhotoCardUploadRouteData().go(context);
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

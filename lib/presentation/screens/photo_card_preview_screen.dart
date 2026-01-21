// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/utils/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/providers/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/providers/payment_failure_provider.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/providers/verify_photo_card_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/widgets/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/widgets/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/widgets/gradient_container.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/widgets/price_box.dart';
import 'package:flutter_snaptag_kiosk/presentation/providers/screens/photo_card_preview_screen_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/providers/states/update_order_info_state.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PhotoCardPreviewScreen extends ConsumerStatefulWidget {
  const PhotoCardPreviewScreen({
    super.key,
  });
  @override
  ConsumerState<PhotoCardPreviewScreen> createState() => _PhotoCardPreviewScreenState();
}

class _PhotoCardPreviewScreenState extends ConsumerState<PhotoCardPreviewScreen> {
  /// 고정 뒷면 이미지 카드 위젯 빌더
  Widget _buildFixedBackPhotoCard({
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: selectedIndex == null ? 1.0 : (selectedIndex == index ? 1.0 : 0.5),
        child: Container(
          width: 226.w,
          height: 355.h,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: imageUrl != null ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder(),
        ),
      ),
    );
  }

  /// 네트워크 이미지 위젯 빌더 (공통 빌더 포함)
  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.fitHeight,
      alignment: Alignment.center,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildEmptyImagePlaceholder(),
    );
  }

  /// 빈 이미지 플레이스홀더
  Widget _buildEmptyImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
      ),
    );
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
              isFixed ? LocaleKeys.choice_select_recommended_image.tr() : LocaleKeys.sub02_txt_01.tr(),
              textAlign: TextAlign.center,
              style: context.typography.kioskBody1B,
            ),
            SizedBox(height: 30.h),
            if (isFixed)
              GradientContainer(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFixedBackPhotoCard(
                      index: 0,
                      selectedIndex: selectedIndex,
                      imageUrl: kiosk?.nominatedBackPhotoCardList.isNotEmpty == true &&
                              (kiosk!.nominatedBackPhotoCardList.isNotEmpty)
                          ? kiosk.nominatedBackPhotoCardList[0].originUrl
                          : null,
                      onTap: () {
                        ref.read(backPhotoTypeProvider.notifier).selectFixed(0);
                      },
                    ),
                    SizedBox(width: 150.w),
                    _buildFixedBackPhotoCard(
                      index: 1,
                      selectedIndex: selectedIndex,
                      imageUrl: kiosk?.nominatedBackPhotoCardList.isNotEmpty == true &&
                              (kiosk!.nominatedBackPhotoCardList.length > 1)
                          ? kiosk.nominatedBackPhotoCardList[1].originUrl
                          : null,
                      onTap: () {
                        ref.read(backPhotoTypeProvider.notifier).selectFixed(1);
                      },
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
                          final imageUrl = data?.formattedBackPhotoCardUrl ?? '';
                          return imageUrl.isNotEmpty ? _buildNetworkImage(imageUrl) : _buildEmptyImagePlaceholder();
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => GeneralErrorWidget(
                          exception: error as Exception,
                          onRetry: () => ref.refresh(verifyPhotoCardProvider),
                        ),
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
                Consumer(
                  builder: (context, ref, child) {
                    final paymentState = ref.watch(photoCardPreviewScreenProviderProvider);
                    final isLoading = paymentState.isLoading;

                    return ElevatedButton(
                      style: context.paymentButtonStyle,
                      onPressed: isLoading
                          ? null // 로딩 중일 때 버튼 비활성화
                          : () async {
                              await SoundManager().playSound();

                              // // 선택된 뒷면 이미지 타입 확인
                              // final selection = ref.read(backPhotoTypeProvider);

                              // if (selection?.type == BackPhotoType.fixed && selection?.fixedIndex != null) {
                              //   // 고정 뒷면 이미지 결제 처리
                              //   final kiosk = ref.read(kioskInfoServiceProvider);
                              //   final selectedIndex = selection!.fixedIndex!;

                              //   if (kiosk != null && selectedIndex < kiosk.nominatedBackPhotoCardList.length) {
                              //     final selectedCard = kiosk.nominatedBackPhotoCardList[selectedIndex];

                              //     final response = await ref.read(kioskRepositoryProvider).getBackPhotoCardByQr(
                              //           GetBackPhotoByQrRequest(
                              //             kioskEventId: kiosk.kioskEventId,
                              //             nominatedBackPhotoCardId: selectedCard.id,
                              //           ),
                              //         );

                              //     ref.read(verifyPhotoCardProvider.notifier).updateState(BackPhotoCardResponse(
                              //         kioskEventId: kiosk.kioskEventId,
                              //         backPhotoCardId: response.backPhotoCardId,
                              //         backPhotoCardOriginUrl: selectedCard.originUrl,
                              //         photoAuthNumber: response.photoAuthNumber,
                              //         formattedBackPhotoCardUrl: response.formattedBackPhotoCardUrl));
                              //   }
                              // }

                              // await ref.read(photoCardPreviewScreenProviderProvider.notifier).payment();
                              // final isPaymentFailed = ref.read(paymentFailureProvider);
                              // if (isPaymentFailed) {
                              //   ref.read(paymentFailureProvider.notifier).reset();
                              //   DialogHelper.showPaymentCardFailedDialog(
                              //     context,
                              //   );
                              //   HomeRouteData().go(context);
                              // }
                              PrintProcessRouteData().go(context);
                            },
                      child: Text(LocaleKeys.sub02_btn_pay.tr()),
                    );
                  },
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

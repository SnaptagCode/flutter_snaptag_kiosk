// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:http/http.dart' as http;
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

    if (error is http.ClientException) {
      await DialogHelper.showCustomDialog(
        context,
        title: error.runtimeType.toString(),
        message: error.toString(),
        buttonText: LocaleKeys.sub01_btn_done.tr(),
      );
      return;
    }
    final exceptionType = switch (error) {
      PaymentException(:final type) => type,
      _ => PaymentExceptionType.unknown,
    };

    switch (exceptionType) {
      // 시스템 관련 오류 - 재시도 가능
      case PaymentExceptionType.cardIssuerTimeout ||
            PaymentExceptionType.ksnetSystemError ||
            PaymentExceptionType.reQueryRequested:

      // 카드 상태 관련 오류 - 다른 카드 사용 필요
      case PaymentExceptionType.stolenOrLostCard ||
            PaymentExceptionType.transactionSuspendedCard ||
            PaymentExceptionType.expiredCard:

      // 결제 금액 관련 오류
      case PaymentExceptionType.amountError ||
            PaymentExceptionType.noAmountEntered ||
            PaymentExceptionType.merchantLimitExceeded:
      default:
        await DialogHelper.showPurchaseFailedDialog(
          context,
          exception: exceptionType,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      photoCardPreviewProvider,
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
          error: _handlePaymentError,
          loading: () => null,
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
                  return const Text('Error loading photo card');
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
                onPressed: () => ref.read(photoCardPreviewProvider.notifier).payment(),
                child: Text(LocaleKeys.sub02_btn_pay.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

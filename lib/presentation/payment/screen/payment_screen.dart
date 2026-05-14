import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/price_box.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/notifier/home_back_photo_type_notifier.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/notifier/payment_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/screen/payment_screen_state.dart';

enum SelectionDesignVariant {
  opacityWithBottomRadio,
  opacityWithTopRightCheck,
  opacityWithBoldBorder,
  opacityWithCenterOverlay,
  opacityWithTopCheckAndBottomRadio,
  animatedScaleOnUnselected,
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  final PaymentScreenState state;
  final void Function(PaymentAction) onAction;

  Widget _buildVariant6AnimatedScaleOnUnselected({
    required BuildContext context,
    required int index,
    required int? selectedIndex,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    final scale = selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.85);
    final opacity = selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _buildFixedBackPhotoCard(
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: buttonColor.withOpacity(0.4),
                      blurRadius: 12.r,
                      spreadRadius: 2.r,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
            imageUrl: imageUrl,
          ),
        ),
      ),
    );
  }

  Widget _buildFixedBackPhotoCard({
    required List<BoxShadow>? boxShadow,
    required String? imageUrl,
  }) {
    return Container(
      width: 226.w,
      height: 355.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? _buildNetworkImage(imageUrl)
            : _buildEmptyImagePlaceholder(),
      ),
    );
  }

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

  Widget _buildEmptyImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildBackPhotoArea(BuildContext context) {
    final isFixed = state.selection?.type == BackPhotoType.fixed;
    final selectedIndex = state.selection?.fixedIndex;
    final nominatedList = state.kiosk?.nominatedBackPhotoCardList ?? [];

    if (!isFixed) {
      if (state.isBackPhotoLoading) return const CircularProgressIndicator();
      if (state.backPhotoError != null) {
        return GeneralErrorWidget(
          exception: state.backPhotoError as Exception,
          onRetry: () => onAction(const PaymentAction.refreshBackPhoto()),
        );
      }
      final imageUrl = state.backPhotoUrl ?? '';
      return imageUrl.isNotEmpty
          ? _buildFixedBackPhotoCard(boxShadow: null, imageUrl: imageUrl)
          : _buildEmptyImagePlaceholder();
    }

    if (nominatedList.isEmpty) return _buildEmptyImagePlaceholder();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (nominatedList.length == 1)
          _buildFixedBackPhotoCard(boxShadow: null, imageUrl: nominatedList[0].originUrl)
        else
          _buildVariant6AnimatedScaleOnUnselected(
            context: context,
            index: 0,
            selectedIndex: selectedIndex,
            imageUrl: nominatedList[0].originUrl,
            onTap: () => onAction(const PaymentAction.selectFixed(0)),
          ),
        if (nominatedList.length > 1) SizedBox(width: 100.w),
        if (nominatedList.length > 1)
          _buildVariant6AnimatedScaleOnUnselected(
            context: context,
            index: 1,
            selectedIndex: selectedIndex,
            imageUrl: nominatedList[1].originUrl,
            onTap: () => onAction(const PaymentAction.selectFixed(1)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final kiosk = state.kiosk;
    final isHwe = kiosk?.isHwe ?? false;
    final isFixed = state.selection?.type == BackPhotoType.fixed;
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isFixed && (kiosk?.nominatedBackPhotoCardList.length ?? 0) > 1
                      ? LocaleKeys.choice_select_recommended_image.tr()
                      : LocaleKeys.sub02_txt_02.tr(),
                  textAlign: TextAlign.center,
                  style: isHwe
                      ? context.typography.vendingTitle1B.copyWith(color: mainTextColor)
                      : context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
                ),
                SizedBox(height: 50.h),
                _buildBackPhotoArea(context),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const PriceBox(),
                    SizedBox(width: 20.w),
                    ElevatedButton(
                      style: context.paymentButtonStyle,
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              await SoundManager().playSound();
                              onAction(const PaymentAction.pay());
                            },
                      child: Text(
                        LocaleKeys.sub02_btn_pay.tr(),
                        style: isHwe
                            ? context.typography.vendingBtn2B.copyWith(
                                color: (kiosk?.buttonTextColor ?? '').toColor(fallback: Colors.white))
                            : context.typography.kioskBtn1B.copyWith(
                                color: (kiosk?.buttonTextColor ?? '').toColor(fallback: Colors.white)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Text(
                  LocaleKeys.sub03_txt_03.tr(),
                  style: isHwe
                      ? context.typography.vendingBody2B
                          .copyWith(color: (kiosk?.couponTextColor ?? '').toColor(fallback: Colors.white))
                      : context.typography.kioskBody2B.copyWith(
                          color: (kiosk?.couponTextColor ?? '').toColor(fallback: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

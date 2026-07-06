import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/front_photo_select/selected_front_photo_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';

/// 앞면 이미지 선택 화면 (선택형 이벤트 전용)
///
/// 홈 '추천이미지' 진입 시 frontPhotoList의 앞면 후보를 사용자가 직접 고른다.
/// 카드를 탭하면 선택 상태를 저장하고 결제(미리보기) 화면으로 이동한다.
class FrontPhotoSelectScreen extends ConsumerWidget {
  const FrontPhotoSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final photos = ref.watch(frontPhotoListProvider);
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;
    final buttonColor = kiosk?.mainButtonColor.toColor() ?? Colors.black;
    final buttonTextColor = kiosk?.buttonTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    // KioskShell이 화면을 높이 무제한 Column(center) 안에 배치하므로
    // Expanded 대신 고정 높이를 사용해야 한다 (가용 영역 약 995.h).
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          LocaleKeys.front_photo_select_title.tr(),
          style: context.typography.kioskBtn1B.copyWith(fontSize: 53.sp, color: mainTextColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        Text(
          LocaleKeys.front_photo_select_subtitle.tr(),
          style: context.typography.kioskBody1B.copyWith(fontSize: 26.sp, color: mainTextColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 680.h,
          child: photos.isEmpty
              ? Center(
                  child: Text(
                    LocaleKeys.front_photo_select_empty.tr(),
                    style: context.typography.kioskBody1B.copyWith(fontSize: 28.sp, color: mainTextColor),
                    textAlign: TextAlign.center,
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 70.w, vertical: 10.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24.h,
                    crossAxisSpacing: 24.w,
                    childAspectRatio: 0.63,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedFrontPhotoProvider.notifier).select(photo);
                        PhotoCardPreviewRouteData().go(context);
                      },
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.white, width: 1.w),
                        ),
                        child: _buildPhotoImage(photo),
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: () {
            ref.read(selectedFrontPhotoProvider.notifier).reset();
            HomeRouteData().go(context);
          },
          child: Container(
            width: 282.w,
            height: 67.h,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.alert_btn_go_to_home.tr(),
              style: context.typography.kioskBtn1B.copyWith(fontSize: 30.sp, color: buttonTextColor),
            ),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  /// 로컬 캐시(embedImage)가 있으면 파일로, 없으면 원본 URL로 표시
  Widget _buildPhotoImage(NominatedPhoto photo) {
    if (photo.embedImage != null) {
      return Image.file(photo.embedImage!, fit: BoxFit.cover);
    }
    return Image.network(
      photo.originUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
      ),
    );
  }
}

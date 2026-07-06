import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/selectable_photo_card.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/front_photo_select/selected_front_photo_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';

/// 앞면 이미지 선택 화면 (선택형 이벤트 전용)
///
/// 뒷면 고정 이미지 선택과 동일한 디자인(SelectablePhotoCard)으로 앞면 후보를
/// 고른 뒤, 하단 '이미지 선택하기' 버튼으로 결제(미리보기) 화면에 진입한다.
class FrontPhotoSelectScreen extends ConsumerWidget {
  const FrontPhotoSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);
    final photos = ref.watch(frontPhotoListProvider);
    final selectedPhoto = ref.watch(selectedFrontPhotoProvider);
    final mainTextColor = kiosk?.mainTextColor.toColor(fallback: Colors.white) ?? Colors.white;
    final buttonColor = kiosk?.mainButtonColor.toColor() ?? Colors.black;
    final buttonTextColor = kiosk?.buttonTextColor.toColor(fallback: Colors.white) ?? Colors.white;

    // 선택된 앞면의 그리드 인덱스 (리스트 갱신으로 사라졌으면 미선택 취급)
    final foundIndex = selectedPhoto == null ? -1 : photos.indexWhere((photo) => photo.id == selectedPhoto.id);
    final selectedIndex = foundIndex < 0 ? null : foundIndex;

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
                    childAspectRatio: 226 / 355,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return SelectablePhotoCard(
                      index: index,
                      selectedIndex: selectedIndex,
                      imageFile: photo.embedImage,
                      imageUrl: photo.originUrl,
                      fit: BoxFit.cover,
                      onTap: () => ref.read(selectedFrontPhotoProvider.notifier).select(photo),
                    );
                  },
                ),
        ),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: selectedPhoto == null ? null : () => PhotoCardPreviewRouteData().go(context),
          child: AnimatedOpacity(
            opacity: selectedPhoto == null ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 282.w,
              height: 67.h,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Text(
                LocaleKeys.choice_select_image.tr(),
                style: context.typography.kioskBtn1B.copyWith(fontSize: 30.sp, color: buttonTextColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

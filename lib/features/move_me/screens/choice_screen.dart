import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/utils/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class ChoiceScreen extends ConsumerWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskInfoServiceProvider);

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '추천 이미지를 선택하거나\n내 사진첩에 있는 이미지를 업로드하세요.',
            style: context.typography.kioskBody1B,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          Text(
            '1EA | 5,000원',
            style: TextStyle(
              fontSize: 20.sp,
              color: Color(0xFFE6BA6B),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 첫 번째 고정 뒷면 이미지 (인덱스 0번만 사용)
              if (kiosk?.nominatedBackPhotoCardList.isNotEmpty == true)
                _buildChoiceButton(
                  context,
                  ref,
                  kiosk!.nominatedBackPhotoCardList[0].originUrl,
                  label: '선택 1', // TODO: Localize
                  onTap: () async {
                    await SoundManager().playSound();
                    // 첫 번째 고정 뒷면 이미지 선택 (인덱스 0)
                    ref.read(backPhotoTypeProvider.notifier).selectFixed(0);
                    PhotoCardPreviewRouteData().go(context);
                  },
                ),
              SizedBox(width: 20.w),
              // 커스텀 이미지 버튼
              _buildChoiceButton(
                context,
                ref,
                kiosk?.defaultCustomBackPhotoCard ?? '',
                label: '선택 2', // TODO: Localize
                onTap: () async {
                  await SoundManager().playSound();
                  // 커스텀 뒷면 이미지 선택
                  ref.read(backPhotoTypeProvider.notifier).selectCustom();
                  PhotoCardUploadRouteData().go(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(BuildContext context, WidgetRef ref, String url,
      {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 307.w,
        height: 485.h,
        margin: EdgeInsets.symmetric(vertical: 22.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        alignment: Alignment.center,
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
                ),
              ),
      ),
    );
  }
}

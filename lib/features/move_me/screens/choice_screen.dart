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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '추천 이미지를 선택하거나\n내 사진첩에 있는 이미지를 업로드하세요.',
            style: context.typography.kioskBody1B,
          ),
          SizedBox(height: 5.h),
          Text(
            '1EA | 5,000원',
            style: TextStyle(
              fontSize: 8.sp,
              color: Color(0xFFE6BA6B),
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChoiceButton(
                context,
                ref,
                kiosk?.nominatedBackPhotoCardList[0] ?? '',
                label: '선택 1', // TODO: Localize
                onTap: () async {
                  await SoundManager().playSound();
                  // PhotoCardUploadRouteData().go(context);
                  PhotoCardPreviewRouteData().go(context);
                },
              ),
              SizedBox(width: 20.w),
              _buildChoiceButton(
                context,
                ref,
                kiosk?.nominatedBackPhotoCardList[1] ?? '',
                label: '선택 2', // TODO: Localize
                onTap: () async {
                  await SoundManager().playSound();
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
    return GradientContainer(
      content: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.network(
          url,
        ),
      ),
    );
  }
}

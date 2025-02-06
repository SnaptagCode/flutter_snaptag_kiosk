import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
<<<<<<< HEAD
=======
import 'package:flutter_snaptag_kiosk/core/utils/sound_manager.dart';
>>>>>>> b5d7f61 (SoLoud 재사용 및 wav 로 오디오 파일 포맷 형식 변경)
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CodeVerificationScreen extends ConsumerWidget {
  const CodeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<BackPhotoCardResponse?>>(
      verifyPhotoCardProvider,
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
        // 에러 처리
        next.whenOrNull(
          error: (error, stack) async {
            await DialogHelper.showErrorDialog(context);
            FileLogger.warning('Error verifying photo card: $error stacktrace $stack');
            // 에러 시 입력값 초기화
            ref.read(authCodeProvider.notifier).clear();
          },
          data: (response) {
            if (response != null) {
              PhotoCardPreviewRouteData().go(context);
              // 성공 후 상태 리셋
              ref.read(authCodeProvider.notifier).clear();
            }
          },
        );
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.sub01_txt_01.tr(),
          style: context.typography.kioskBody1B,
        ),
        ...[
          LocaleKeys.sub01_txt_02.tr().isNotEmpty
              ? SizedBox(height: 12.h)
              : SizedBox(height: 0)
        ],
        Text(
          LocaleKeys.sub01_txt_02.tr(),
          style: context.typography.kioskBody1B,
        ).validate(),
        SizedBox(
          height: 40.h,
        ),
        SizedBox(
          width: 418.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InputDisplay(),
              SizedBox(
                height: 30.h,
              ),
              _NumericPad(),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputDisplay extends ConsumerWidget {
  const _InputDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keypadState = ref.watch(authCodeProvider);
    return Container(
      width: 478.w,
      height: 86.h,
      decoration: context.keypadDisplayDecoration,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    keypadState,
                    textAlign: TextAlign.center,
                    style: context.typography.kioskInput1B
                        .copyWith(color: Colors.black),
                  ),
                ),
              ]),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: ref.read(authCodeProvider.notifier).clear,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Image.asset(
                  SnaptagImages.close,
                  width: 38.w,
                  height: 38.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumericPad extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int row = 0; row < 4; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int col = 0; col < 3; col++) ...[
                _buildGridItem(context, ref, row * 3 + col),
                if (col < 2) SizedBox(width: 10.w), // 컬럼 사이 간격 추가
              ],
            ],
          ),
          if (row < 3) SizedBox(height: 10.h), // 로우 사이 간격 추가
        ],
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, WidgetRef ref, int index) {
    if (index == 9) {
      return ElevatedButton(
        style: context.keypadNumberStyle,
        onPressed: () {
          SoundManager().playSound();
          ref.read(authCodeProvider.notifier).removeLast();
        },
        child: SizedBox(
          width: 60.w,
          height: 60.h,
          child: Image.asset(
            SnaptagImages.arrowBack,
          ),
        ),
      );
    }
    if (index == 10) {
      return ElevatedButton(
        style: context.keypadNumberStyle,
        onPressed: () {
          SoundManager().playSound();
          ;
          ref.read(authCodeProvider.notifier).addNumber('0');
        },
        child: Text('0'),
      );
    }
    if (index == 11) {
      return ElevatedButton(
        style: context.keypadCompleteStyle,
        onPressed: () {
          SoundManager().playSound();
          ;
          final code = ref.read(authCodeProvider);
          if (ref.read(authCodeProvider.notifier).isValid()) {
            ref.read(verifyPhotoCardProvider.notifier).verify(code);
          }
        },
        child: Text(LocaleKeys.sub01_btn_done.tr()),
      );
    }
    return ElevatedButton(
      style: context.keypadNumberStyle,
      onPressed: () {
        SoundManager().playSound();
        ;
        ref.read(authCodeProvider.notifier).addNumber('${index + 1}');
      },
      child: Text('${index + 1}'),
    );
  }
}

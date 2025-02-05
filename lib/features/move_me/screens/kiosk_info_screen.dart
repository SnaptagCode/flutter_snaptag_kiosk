import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KioskInfoScreen extends ConsumerWidget {
  const KioskInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.only(left: 30.w),
          icon: SvgPicture.asset(SnaptagSvg.arrowBack),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('이벤트 미리보기'),
        excludeHeaderSemantics: false,
        backgroundColor: Colors.white.withOpacity(0.7),
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await DialogHelper.showSetupDialog(context, title: '최신 이벤트로 새로고침 됩니다.');
              if (result == true) {
                await ref.read(asyncKioskInfoProvider.notifier).refresh();
              }
            },
            icon: SvgPicture.asset(
              'assets/icons/refresh.svg',
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: ref.watch(asyncKioskInfoProvider).when(
        data: (info) {
          return Column(
            children: [
              Image.network(
                info.topBannerUrl,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: const Text('이미지를 찾을 수 없습니다.'),
                  );
                },
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    info.mainImageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: const Text('이미지를 찾을 수 없습니다.'),
                      );
                    },
                  ),
                  if (F.appFlavor == Flavor.dev) KioskInfoWidget(info: info),
                ],
              ),
            ],
          );
        },
        error: (error, stack) {
          return GeneralErrorWidget(
            exception: error as Exception,
            onRetry: () => ref.refresh(asyncKioskInfoProvider),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

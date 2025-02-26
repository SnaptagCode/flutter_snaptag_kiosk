import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KioskInfoScreen extends ConsumerWidget {
  const KioskInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(kioskInfoServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.only(left: 30.w),
          icon: SvgPicture.asset(SnaptagSvg.arrowBack),
          onPressed: () async {
            final result = await DialogHelper.showSetupDialog(
              context,
              title: '메인페이지로 이동합니다.',
            );
            if (result) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('이벤트 미리보기'),
        excludeHeaderSemantics: false,
        backgroundColor: Colors.white.withOpacity(0.7),
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              String? value = await showDialog<String>(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    insetPadding: EdgeInsets.symmetric(horizontal: 100.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    content: SizedBox(
                      width: 418.w,
                      height: 600.h,
                      child: AuthCodeKeypad(
                        onCompleted: (code) {
                          // 완료 시 실행할 로직
                          print("입력된 코드: $code");
                          return Navigator.pop(context, code);
                        },
                      ),
                    ),
                  );
                },
              );

              if (value == null || value.isEmpty) return; // 값이 없으면 종료

              final result = await DialogHelper.showSetupDialog(context, title: '최신 이벤트로 새로고침 됩니다.');
              if (result == true) {
                await ref.read(kioskInfoServiceProvider.notifier).refreshWithMachineId(int.parse(value));
              }
            },
            icon: SvgPicture.asset(
              'assets/icons/refresh.svg',
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Builder(builder: (context) {
        if (info == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                '진행중인\n이벤트가 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        return Column(
          children: [
            Image.network(
              info.topBannerUrl,
              errorBuilder: (context, error, stackTrace) {
                return Flexible(
                  child: Center(
                    child: const CircularProgressIndicator(),
                  ),
                );
              },
            ),
            if (info.topBannerUrl.isNotEmpty)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    info.mainImageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return Flexible(
                        flex: 3,
                        child: const CircularProgressIndicator(),
                      );
                    },
                  ),
                  if (F.appFlavor == Flavor.dev) KioskInfoWidget(info: info),
                ],
              ),
          ],
        );
      }),
    );
  }
}

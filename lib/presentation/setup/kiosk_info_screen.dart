import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/data/models/request/unique_key_request.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/kiosk_info_widget.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/uuid_provider.dart';
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
              showCancelButton: true,
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
              // NOTE: ref는 build 동안에만 안전하게 사용할 수 있으므로,
              // 비동기 갭(첫 await) 이전에 필요한 의존성을 모두 read 해둔다.
              final deviceUuidFuture = ref.read(deviceUuidProvider.future);
              final kioskInfoNotifier = ref.read(kioskInfoServiceProvider.notifier);
              final kioskRepository = ref.read(kioskRepositoryProvider);

              String? value = await DialogHelper.showKeypadDialog(context, mode: ModeType.event);

              if (value == null || value.isEmpty) return; // 값이 없으면 종료

              final result =
                  await DialogHelper.showSetupDialog(context, title: '최신 이벤트로 새로고침 됩니다.', showCancelButton: true);
              if (result == true) {
                final machineId = int.parse(value);
                final deviceUUID = await deviceUuidFuture;

                await kioskInfoNotifier.refreshWithMachineId(machineId);

                await kioskRepository.createUniqueKeyHistory(
                  request: UniqueKeyRequest(
                    machineId: machineId.toString(),
                    uniqueKey: deviceUUID,
                  ),
                );

                SlackLogService().sendBroadcastLogToSlack(InfoKey.inspectionStart.key);
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class KioskInfoScreen extends ConsumerWidget {
  const KioskInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 비동기 상태 감시
    final info = ref.watch(storageServiceProvider).settings;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('이벤트 미리보기'),
        excludeHeaderSemantics: false,
        backgroundColor: Colors.white.withOpacity(0.7),
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(asyncKioskInfoProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Image.network(info.topBannerUrl),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.network(info.mainImageUrl),
              KioskInfoWidget(info: info),
            ],
          ),
        ],
      ),
    );
  }
}

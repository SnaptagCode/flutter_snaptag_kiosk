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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kiosk ID: ${info.kioskMachineId}'),
            Text('Name: ${info.kioskMachineName}'),
            Text('Description: ${info.kioskMachineDescription}'),
            Text('Event ID: ${info.kioskEventId}'),
            Text('Price: ${info.photoCardPrice}'),
            Text('Printed Event Name: ${info.printedEventName}'),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: Color(int.parse(info.mainButtonColor.replaceFirst('#', '0xff'))),
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: Color(int.parse(info.buttonTextColor.replaceFirst('#', '0xff'))),
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: Color(int.parse(info.couponTextColor.replaceFirst('#', '0xff'))),
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: Color(int.parse(info.mainTextColor.replaceFirst('#', '0xff'))),
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: Color(int.parse(info.popupButtonColor.replaceFirst('#', '0xff'))),
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: Color(int.parse(info.keyPadColor.replaceFirst('#', '0xff'))),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Image.network(info.topBannerUrl)),
                Expanded(child: Image.network(info.mainImageUrl)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(asyncKioskInfoProvider.notifier).refresh();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

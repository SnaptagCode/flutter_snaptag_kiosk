import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class KioskInfoScreen extends ConsumerWidget {
  const KioskInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 비동기 상태 감시
    final info = ref.watch(yamlStorageServiceProvider).settings;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(info.topBannerUrl),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.network(info.mainImageUrl),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Kiosk ID: ${info.kioskMachineId}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Name: ${info.kioskMachineName}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Description: ${info.kioskMachineDescription}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Event ID: ${info.kioskEventId}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Price: ${info.photoCardPrice}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Printed Event Name: ${info.printedEventName}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(8),
                          color: Color(int.parse(info.mainButtonColor.replaceFirst('#', '0xff'))),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(8),
                          color: Color(int.parse(info.buttonTextColor.replaceFirst('#', '0xff'))),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(8),
                          color: Color(int.parse(info.couponTextColor.replaceFirst('#', '0xff'))),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(8),
                          color: Color(int.parse(info.mainTextColor.replaceFirst('#', '0xff'))),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(8),
                          color: Color(int.parse(info.popupButtonColor.replaceFirst('#', '0xff'))),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(8),
                          color: Color(int.parse(info.keyPadColor.replaceFirst('#', '0xff'))),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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

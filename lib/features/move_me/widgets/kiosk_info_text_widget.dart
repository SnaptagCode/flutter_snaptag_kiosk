import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class KioskInfoTextWidget extends StatelessWidget {
  const KioskInfoTextWidget({
    super.key,
    required this.info,
  });

  final KioskMachineInfo info;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'KioskID ${info.kioskMachineId} - EventID ${info.kioskEventId}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${info.kioskMachineName} - ${info.kioskMachineDescription}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${info.printedEventName} - ${info.photoCardPrice}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
        Row(),
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
    );
  }
}

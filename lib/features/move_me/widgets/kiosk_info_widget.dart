import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class KioskInfoWidget extends ConsumerWidget {
  const KioskInfoWidget({
    super.key,
    required this.info,
  });

  final KioskMachineInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> frontPhotoListState = ref.watch(frontPhotoListProvider);
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final photo in frontPhotoListState)
              Image.file(
                File(photo),
                width: ScreenUtil().screenWidth / 10,
                fit: BoxFit.cover,
              ),
          ]),
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
    );
  }
}

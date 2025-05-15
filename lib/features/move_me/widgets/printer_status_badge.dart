import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingPrinterStatusBadge extends ConsumerWidget {
  const FloatingPrinterStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSingle = ref.watch(pagePrintProvider) == PagePrintType.single;

    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Container(
            //padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SvgPicture.asset(
                isSingle? SnaptagSvg.printSingle : SnaptagSvg.printDouble,
                width: 44.w,
                height: 44.w,
              ),
            ),
          ),
    );
  }
}

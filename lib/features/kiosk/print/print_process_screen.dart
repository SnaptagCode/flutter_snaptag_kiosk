import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class PrintProcessScreen extends ConsumerStatefulWidget {
  const PrintProcessScreen({super.key});

  @override
  ConsumerState<PrintProcessScreen> createState() => _PrintProcessScreenState();
}

class _PrintProcessScreenState extends ConsumerState<PrintProcessScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.sub03_txt_01.tr(),
            textAlign: TextAlign.center,
            style: context.typography.kioskBody1B,
          ),
          SizedBox(height: 30.h),
          GradientContainer(
            content: Padding(
              padding: EdgeInsets.all(8.r),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.asset(
                  SnaptagImages.printLoading,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            LocaleKeys.sub03_txt_02.tr(),
            textAlign: TextAlign.center,
            style: context.typography.kioskBody2B,
          ),
        ],
      ),
    );
  }
}

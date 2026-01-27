import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/front_images_action.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/labcurity_image_test.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/pager_print_type_toggle.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/test/payment_test_widget.dart';
import 'package:flutter_snaptag_kiosk/presentation/test/print_test_widget.dart';
import 'package:flutter_svg/svg.dart';

class UnitTestScreen extends ConsumerStatefulWidget {
  const UnitTestScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UnitTestScreenState();
}

class _UnitTestScreenState extends ConsumerState<UnitTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.only(left: 30.w),
          icon: SvgPicture.asset(SnaptagSvg.arrowBack),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('양면 / 단면 설정', style: Theme.of(context).textTheme.headlineSmall),
            PagerPrintTypeToggle(),
            Text('프론트 이미지', style: Theme.of(context).textTheme.headlineSmall),
            FrontImagesAction(),
            Text('결제 테스트', style: Theme.of(context).textTheme.headlineSmall),
            PaymentTestWidget(),
            Text('Labcurity 이미지 테스트', style: Theme.of(context).textTheme.headlineSmall),
            LabcurityImageTestWidget(),
            Text('Print 테스트', style: Theme.of(context).textTheme.headlineSmall),
            PrintTestWidget(),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class UnitTestScreen extends ConsumerStatefulWidget {
  const UnitTestScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UnitTestScreenState();
}

class _UnitTestScreenState extends ConsumerState<UnitTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

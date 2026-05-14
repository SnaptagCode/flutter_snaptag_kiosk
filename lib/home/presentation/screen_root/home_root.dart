import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/home/presentation/notifier/back_photo_type_notifier.dart';
import 'package:flutter_snaptag_kiosk/home/presentation/screen/home_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/routers/router.dart';

class HomeRoot extends ConsumerWidget {
  const HomeRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomeScreen(
      onFixedSelected: (int index) {
        ref.read(backPhotoTypeNotifierProvider.notifier).selectFixed(index);
        PhotoCardPreviewRouteData().go(context);
      },
      onCustomSelected: () {
        ref.read(backPhotoTypeNotifierProvider.notifier).selectCustom();
        CodeVerificationRouteData().go(context);
      },
    );
  }
}

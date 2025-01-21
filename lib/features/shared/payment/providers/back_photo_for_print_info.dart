import 'package:flutter_snaptag_kiosk/data/models/entities/back_photo_for_print.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'back_photo_for_print_info.g.dart';

@riverpod
class BackPhotoForPrintInfo extends _$BackPhotoForPrintInfo {
  @override
  BackPhotoForPrint? build() => null;

  void update(BackPhotoForPrint order) {
    state = order;
  }

  void reset() {
    state = null;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'approval_info_provider.g.dart';

@Riverpod(keepAlive: false)
class ApprovalInfo extends _$ApprovalInfo {
  @override
  PaymentResponse? build() => null;

  void update(PaymentResponse response) {
    state = response;
  }
}

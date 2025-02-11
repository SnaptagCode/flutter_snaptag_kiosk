import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_process_screen_provider.g.dart';

@riverpod
class PrintProcessScreenProvider extends _$PrintProcessScreenProvider {
  @override
  FutureOr<bool> build() async {
    try {
      return await ref.read(printServiceProvider.notifier).print();
    } catch (e) {
      rethrow;
    }
  }
}

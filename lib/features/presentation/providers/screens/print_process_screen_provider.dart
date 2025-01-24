import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_process_screen_provider.g.dart';

@riverpod
class PrintProcessScreenProvider extends _$PrintProcessScreenProvider {
  @override
  FutureOr<void> build() {
    state = const AsyncValue.loading();
    return _startPrinting();
  }

  Future<void> _startPrinting() async {
    try {
      await ref.read(printServiceProvider.notifier).print();
      state = const AsyncValue.data(null);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      rethrow;
    }
  }
}

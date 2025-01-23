import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_process_screen_provider.g.dart';

@riverpod
class PrintProcessScreenProvider extends _$PrintProcessScreenProvider {
  @override
  FutureOr<void> build() async {
    state = const AsyncValue.loading(); // 명시적 loading 설정
    return _startPrinting();
  }

  Future<void> _startPrinting() async {
    return await AsyncValue.guard(() async {
      await ref.read(printServiceProvider.notifier).print();
    }).then((value) => value.when(
          data: (_) => null,
          error: (err, stack) => throw err,
          loading: () => null,
        ));
  }
}

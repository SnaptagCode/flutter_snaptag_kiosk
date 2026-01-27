import 'package:flutter_snaptag_kiosk/presentation/print/print_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_process_screen_provider.g.dart';

@riverpod
class PrintProcessScreenProvider extends _$PrintProcessScreenProvider {
  @override
  FutureOr<void> build() async {
    try {
      await ref.read(printServiceProvider.notifier).printCard();
    } catch (e) {
      rethrow;
    }
  }
}

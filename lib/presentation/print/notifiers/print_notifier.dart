import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/notifiers/print_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/print_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_notifier.g.dart';

@riverpod
class PrintNotifier extends _$PrintNotifier {
  @override
  PrintState build() {
    _startPrint();
    return const PrintState.initial();
  }

  Future<void> _startPrint() async {
    state = const PrintState.loading();
    try {
      await ref.read(printServiceProvider.notifier).printCard();
      state = const PrintState.success();
    } catch (e, stack) {
      logger.e('PrintNotifier failure', error: e, stackTrace: stack);
      state = PrintState.failure(e, stack);
    }
  }
}

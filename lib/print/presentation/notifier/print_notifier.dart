import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/print/module/print_di.dart';
import 'package:flutter_snaptag_kiosk/print/presentation/notifier/print_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_notifier.g.dart';

@riverpod
class PrintNotifier extends _$PrintNotifier {
  late final PrintCardUseCase _printCardUseCase;

  @override
  PrintState build() {
    _printCardUseCase = ref.watch(printCardUseCaseProvider);
    _startPrint();
    return const PrintState.initial();
  }

  Future<void> _startPrint() async {
    state = const PrintState.loading();
    try {
      await _printCardUseCase.call();
      state = const PrintState.success();
    } catch (e, stack) {
      logger.e('PrintNotifier failure', error: e, stackTrace: stack);
      state = PrintState.failure(e, stack);
    }
  }
}

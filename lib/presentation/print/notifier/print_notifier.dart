import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/domain/domain.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/notifier/create_order_info_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/notifier/payment_response_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/di/print_di.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/notifier/print_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
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
      final params = _buildParams();
      await _printCardUseCase.call(params);
      state = const PrintState.success();
    } catch (e, stack) {
      logger.e('PrintNotifier failure', error: e, stackTrace: stack);
      state = PrintState.failure(e, stack);
    }
  }

  PrintCardParams _buildParams() {
    final backPhotoCard = ref.read(backPhotoSessionProvider).value;
    final approvalInfo = ref.read(paymentResponseStateProvider);
    final kioskInfo = ref.read(kioskInfoServiceProvider);

    if (backPhotoCard == null) throw Exception('No back photo card response info available');
    if (approvalInfo == null) throw Exception('No payment approval info available');

    return PrintCardParams(
      backPhotoCardId: backPhotoCard.backPhotoCardId,
      kioskOrderId: ref.read(createOrderInfoProvider)?.orderId ?? 0,
      kioskMachineId: kioskInfo?.kioskMachineId ?? 0,
      kioskEventId: kioskInfo?.kioskEventId ?? 0,
      kioskMachineName: kioskInfo?.kioskMachineName ?? '',
      isSingleMode: ref.read(pagePrintProvider) == PagePrintType.single,
    );
  }
}

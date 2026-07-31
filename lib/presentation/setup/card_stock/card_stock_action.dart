import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';

const int kCardStockMax = 300;

class CardStockOutcome {
  final int count;
  final bool recordedOnServer;
  const CardStockOutcome({required this.count, required this.recordedOnServer});
}

Future<CardStockOutcome?> showCardStockDialog(BuildContext context, WidgetRef ref) async {
  final cardCount = ref.read(cardCountProvider.notifier);
  final kioskRepository = ref.read(kioskRepositoryProvider);
  final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;

  final requestCount = await _promptCount(context);
  if (requestCount == null) return null;

  int appliedCount = requestCount;
  bool recorded = false;
  String failureReason = '';

  if (machineId == 0) {
    failureReason = '기기 정보를 불러오지 못했습니다.';
  } else {
    try {
      final response = await kioskRepository.setCardStock(
        CardStockSetRequest(machineId: machineId, requestCount: requestCount),
      );
      appliedCount = response.cardCurrentCount;
      recorded = true;
    } catch (e) {
      failureReason = _describeFailure(e);
      SlackLogService().sendErrorLogToSlack('*[MachineId : $machineId]* 카드 적재 기록 실패 (요청: $requestCount장): $e');
    }
  }

  cardCount.update(appliedCount);

  if (!recorded && context.mounted) {
    await DialogHelper.showSetupDialog(
      context,
      title: '카드 수량 서버 기록 실패',
      content: '$appliedCount장으로 이 기기에만 반영했습니다.\n$failureReason',
    );
  }

  return CardStockOutcome(count: appliedCount, recordedOnServer: recorded);
}

Future<int?> _promptCount(BuildContext context) async {
  final value = await DialogHelper.showKeypadDialog(context, mode: ModeType.card);
  if (value == null || value.isEmpty) return null;

  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 0 || parsed > kCardStockMax) {
    if (!context.mounted) return null;
    await DialogHelper.showSetupDialog(
      context,
      title: '카드 수량을 확인해주세요.',
      content: '0장 이상 $kCardStockMax장 이하로 입력해 주세요.',
    );
    return null;
  }
  return parsed;
}

String _describeFailure(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
  }
  return '네트워크 상태를 확인해 주세요.';
}

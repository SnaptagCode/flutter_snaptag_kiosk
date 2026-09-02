import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_connect_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';

const Duration kCrashRecoveryWindow = Duration(seconds: 10);

class CrashRecoveryResult {
  const CrashRecoveryResult.proceed() : proceed = true, reason = null;
  const CrashRecoveryResult.cancelled() : proceed = false, reason = '관리자 취소';
  const CrashRecoveryResult.stopped(this.reason) : proceed = false;

  final bool proceed;
  final String? reason;
}

class CrashRecoveryDialog extends ConsumerStatefulWidget {
  const CrashRecoveryDialog({
    super.key,
    required this.printMode,
    this.window = kCrashRecoveryWindow,
  });

  final PagePrintType printMode;
  final Duration window;

  @override
  ConsumerState<CrashRecoveryDialog> createState() => _CrashRecoveryDialogState();
}

class _CrashRecoveryDialogState extends ConsumerState<CrashRecoveryDialog> {
  Timer? _ticker;
  late int _remaining;
  bool _readerReady = false;
  bool _readerChecking = false;
  String _readerLabel = '확인 중';
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.window.inSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    if (_closed) return;

    _remaining -= 1;

    final printerReady = ref.read(printerConnectProvider) == PrinterConnectState.connected;

    if (printerReady && !_readerReady && !_readerChecking) {
      _readerChecking = true;
      try {
        await ref.read(paymentGatewayProvider).check();
        _readerReady = true;
        _readerLabel = '준비됨';
      } catch (_) {
        _readerLabel = '응답 없음';
      }
      _readerChecking = false;
    }

    if (_remaining > 0) {
      if (mounted) setState(() {});
      return;
    }

    _close(
      printerReady && _readerReady
          ? const CrashRecoveryResult.proceed()
          : CrashRecoveryResult.stopped(_notReadyReason),
    );
  }

  String get _modeLabel => switch (widget.printMode) {
        PagePrintType.single => '단면',
        PagePrintType.double => '양면',
        PagePrintType.none => '미선택',
      };

  void _close(CrashRecoveryResult result) {
    if (_closed) return;
    _closed = true;
    _ticker?.cancel();
    if (mounted) Navigator.of(context).pop(result);
  }

  String get _notReadyReason {
    final printerReady = ref.read(printerConnectProvider) == PrinterConnectState.connected;
    final parts = [
      if (!printerReady) '프린터 미준비',
      if (!_readerReady) '리더기 ${printerReady ? _readerLabel : '확인 안 됨'}',
    ];
    return '장치 미준비 (${parts.join(' · ')})';
  }

  @override
  Widget build(BuildContext context) {
    final isHwe = context.isHwe;
    final printerReady = ref.watch(printerConnectProvider) == PrinterConnectState.connected;
    final allReady = printerReady && _readerReady;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: context.locale.languageCode == 'ja' ? 'MPLUSRounded' : 'Cafe24Ssurround2',
      ),
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 211.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60.h, left: 40.w, right: 40.w),
                child: Text(
                  '비정상 종료가 감지되었습니다',
                  textAlign: TextAlign.center,
                  style: context.typography.kioskAlert1B.copyWith(
                    fontFamily: isHwe ? 'Hanwha' : 'Pretendard',
                    color: Colors.black,
                    fontSize: isHwe ? 52.sp : 42.sp,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.h, left: 40.w, right: 40.w),
              child: Text(
                '$_modeLabel 인쇄로 이벤트 화면에 돌아갑니다.\n장치가 준비되는 대로 이동합니다.',
                textAlign: TextAlign.center,
                style: context.typography.kioskAlert2M.copyWith(
                  color: Colors.black,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.h, left: 40.w, right: 40.w),
              child: Text(
                '프린터 ${printerReady ? '준비됨' : '준비 중'}  ·  리더기 ${printerReady ? _readerLabel : '대기'}      $_remaining초',
                textAlign: TextAlign.center,
                style: context.typography.kioskAlert2M.copyWith(
                  color: allReady ? const Color(0xFF1E9E5A) : const Color(0xFF888888),
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 36.h, bottom: 40.h, left: 40.w, right: 40.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        unawaited(SoundManager().playSound());
                        _close(const CrashRecoveryResult.cancelled());
                      },
                      style: context.setupDialogCancelButtonStyle,
                      child: const Text('취소'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        unawaited(SoundManager().playSound());
                        _close(const CrashRecoveryResult.proceed());
                      },
                      style: context.setupDialogConfirmButtonStyle,
                      child: const Text('지금 이동'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

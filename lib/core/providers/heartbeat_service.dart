import 'dart:async';

import 'package:flutter_snaptag_kiosk/core/common/logger/logger_service.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/local/heartbeat_note.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/local/heartbeat_writer.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/routers/go_router.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'heartbeat_service.g.dart';

const Duration _beatInterval = Duration(seconds: 30);

@Riverpod(keepAlive: true)
class HeartbeatService extends _$HeartbeatService {
  Timer? _timer;
  Future<void>? _starting;
  Future<void> _pending = Future<void>.value();
  GoRouterDelegate? _delegate;
  HeartbeatNote? _previous;
  bool _noteTaken = false;
  bool _shuttingDown = false;
  String _screen = kHeartbeatScreenSetup;

  @override
  bool build() {
    ref.onDispose(_detach);
    return false;
  }

  Future<void> ensureStarted() => _starting ??= _start();

  Future<void> _start() async {
    _previous = await readHeartbeat();

    _delegate = ref.read(routerProvider).routerDelegate;
    _syncScreen();
    _delegate!.addListener(_onRouteChanged);

    await _beat();
    _timer = Timer.periodic(_beatInterval, (_) => unawaited(_beat()));
    state = true;
  }

  HeartbeatNote? get pendingRecovery => _noteTaken ? null : _previous;

  Future<void> markRecoveryDone() {
    _noteTaken = true;
    return _beat();
  }

  Future<void> markShutdown() {
    _shuttingDown = true;
    return _beat();
  }

  void _onRouteChanged() {
    if (_syncScreen()) unawaited(_beat());
  }

  bool _syncScreen() {
    final next = screenForPath(_delegate?.currentConfiguration.uri.path ?? '');
    if (next == _screen) return false;
    _screen = next;
    return true;
  }

  Future<void> _beat() {
    final next = _pending.then((_) => _write());
    _pending = next;
    return next;
  }

  Future<void> _write() async {
    final onCustomerScreen = _screen == kHeartbeatScreenCustomer;
    try {
      await writeHeartbeat(
        restartOnCrash: onCustomerScreen && !_shuttingDown,
        eventId: '${ref.read(kioskInfoServiceProvider)?.kioskEventId ?? 0}',
        eventRunning: onCustomerScreen,
        screen: _screen,
        printMode: ref.read(pagePrintProvider).name,
      );
    } catch (error) {
      logger.w('heartbeat write failed: $error');
    }
  }

  void _detach() {
    _timer?.cancel();
    _timer = null;
    _delegate?.removeListener(_onRouteChanged);
    _delegate = null;
  }
}

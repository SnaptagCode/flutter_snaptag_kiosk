import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/core/common/logger/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_timeout_provider.g.dart';

/// 홈 자동복귀 타임아웃 타이머 (one-shot)
///
/// 주의: `Timer` 만료 콜백은 이벤트 큐에 올라간 뒤 실행되므로,
/// `cancelTimer()` 호출과 경합(race)되면 "취소했는데도 콜백이 실행"처럼 보일 수 있습니다.
/// 이를 방지하기 위해 generation(세대) 토큰으로 구형 콜백을 무시합니다.
@Riverpod(keepAlive: true)
class HomeTimeoutNotifier extends _$HomeTimeoutNotifier {
  Timer? _timer;
  final Duration _duration = const Duration(seconds: 60);
  VoidCallback? _savedCallback;
  int _generation = 0;

  @override
  bool build() {
    logger.i('⏱️ TimeoutToHome: Building timer (keepAlive: true)');
    // provider가 dispose 될 때 타이머가 남지 않도록 보장
    ref.onDispose(() {
      logger.i('⏱️ TimeoutToHome: Provider disposing, canceling timer');
      cancelTimer();
    });
    return false;
  }

  /// 타이머 시작 (one-shot)
  void startTimer({
    required VoidCallback onTimeout,
  }) {
    logger.i('⏱️ TimeoutToHome: Starting timer for route: $_duration');

    _timer?.cancel();

    _generation++;
    final currentGeneration = _generation;

    _savedCallback = onTimeout;

    logger.i('⏱️ TimeoutToHome: Timer expired (currentGeneration: $currentGeneration)');

    _timer = Timer(_duration, () {
      if (currentGeneration != _generation) {
        logger.i(
          '⏱️ TimeoutToHome: Timer expired but ignored (generation mismatch: $currentGeneration vs $_generation)',
        );
        return;
      }

      logger.i('⏱️ TimeoutToHome: Timer expired (generation: $currentGeneration, _generation: $_generation)');
      _savedCallback?.call();
    });
  }

  /// 타이머 취소
  void cancelTimer() {
    // 구형 콜백 무시
    _generation++;

    logger.i('⏱️ TimeoutToHome: Canceling timer (generation: $_generation)');
    _timer?.cancel();
    _timer = null;
    _savedCallback = null;
  }

  /// 타이머 리셋 (취소 후 다시 시작)
  void resetTimer({
    required VoidCallback onTimeout,
  }) {
    logger.i('⏱️ TimeoutToHome: Resetting timer for route: $_duration');
    cancelTimer();
    startTimer(onTimeout: onTimeout);
  }

  /// 타이머 재개 (저장된 콜백이 있을 때만)
  void resumeTimer() {
    final cb = _savedCallback;
    if (cb == null) return;
    logger.i('⏱️ TimeoutToHome: Resuming timer for route: $_duration');
    startTimer(onTimeout: cb);
  }
}

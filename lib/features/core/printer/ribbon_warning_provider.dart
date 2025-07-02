import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';

part 'ribbon_warning_provider.g.dart';

/// 리본/필름 경고 상태를 관리하는 클래스
class RibbonWarningState {
  final bool isSentUnder20Ribbon;
  final bool isSentUnder20Film;
  final bool isSentUnder10Ribbon;
  final bool isSentUnder10Film;
  final bool isSentUnder5Ribbon;
  final bool isSentUnder5Film;
  final bool isSentUnder2Ribbon;
  final bool isSentUnder2Film;

  // 마지막으로 경고를 보낸 시점의 리본/필름 잔량
  final double lastWarnedRibbonLevel;
  final double lastWarnedFilmLevel;

  const RibbonWarningState({
    this.isSentUnder20Ribbon = false,
    this.isSentUnder20Film = false,
    this.isSentUnder10Ribbon = false,
    this.isSentUnder10Film = false,
    this.isSentUnder5Ribbon = false,
    this.isSentUnder5Film = false,
    this.isSentUnder2Ribbon = false,
    this.isSentUnder2Film = false,
    this.lastWarnedRibbonLevel = 100.0, // 초기값은 100%로 설정
    this.lastWarnedFilmLevel = 100.0, // 초기값은 100%로 설정
  });

  RibbonWarningState copyWith({
    bool? isSentUnder20Ribbon,
    bool? isSentUnder20Film,
    bool? isSentUnder10Ribbon,
    bool? isSentUnder10Film,
    bool? isSentUnder5Ribbon,
    bool? isSentUnder5Film,
    bool? isSentUnder2Ribbon,
    bool? isSentUnder2Film,
    double? lastWarnedRibbonLevel,
    double? lastWarnedFilmLevel,
  }) {
    return RibbonWarningState(
      isSentUnder20Ribbon: isSentUnder20Ribbon ?? this.isSentUnder20Ribbon,
      isSentUnder20Film: isSentUnder20Film ?? this.isSentUnder20Film,
      isSentUnder10Ribbon: isSentUnder10Ribbon ?? this.isSentUnder10Ribbon,
      isSentUnder10Film: isSentUnder10Film ?? this.isSentUnder10Film,
      isSentUnder5Ribbon: isSentUnder5Ribbon ?? this.isSentUnder5Ribbon,
      isSentUnder5Film: isSentUnder5Film ?? this.isSentUnder5Film,
      isSentUnder2Ribbon: isSentUnder2Ribbon ?? this.isSentUnder2Ribbon,
      isSentUnder2Film: isSentUnder2Film ?? this.isSentUnder2Film,
      lastWarnedRibbonLevel: lastWarnedRibbonLevel ?? this.lastWarnedRibbonLevel,
      lastWarnedFilmLevel: lastWarnedFilmLevel ?? this.lastWarnedFilmLevel,
    );
  }

  /// 모든 상태 초기화
  RibbonWarningState reset() {
    return const RibbonWarningState();
  }
}

/// 리본/필름 경고 상태를 관리하는 Provider (코드 생성 방식)
@Riverpod(keepAlive: true)
class RibbonWarning extends _$RibbonWarning {
  @override
  RibbonWarningState build() {
    return const RibbonWarningState();
  }

  /// 20% 미만 리본 경고 전송 상태 설정
  void setRibbonUnder20Sent(double currentLevel) {
    state = state.copyWith(
      isSentUnder20Ribbon: true,
      lastWarnedRibbonLevel: currentLevel,
    );
  }

  /// 20% 미만 필름 경고 전송 상태 설정
  void setFilmUnder20Sent(double currentLevel) {
    state = state.copyWith(
      isSentUnder20Film: true,
      lastWarnedFilmLevel: currentLevel,
    );
  }

  /// 10% 미만 리본 경고 전송 상태 설정
  void setRibbonUnder10Sent(double currentLevel) {
    state = state.copyWith(
      isSentUnder10Ribbon: true,
      lastWarnedRibbonLevel: currentLevel,
    );
  }

  /// 10% 미만 필름 경고 전송 상태 설정
  void setFilmUnder10Sent(double currentLevel) {
    state = state.copyWith(
      isSentUnder10Film: true,
      lastWarnedFilmLevel: currentLevel,
    );
  }

  /// 5% 미만 리본 경고 전송 상태 설정
  void setRibbonUnder5Sent(double currentLevel) {
    state = state.copyWith(
      isSentUnder5Ribbon: true,
      lastWarnedRibbonLevel: currentLevel,
    );
  }

  /// 5% 미만 필름 경고 전송 상태 설정
  void setFilmUnder5Sent(double currentLevel) {
    state = state.copyWith(
      isSentUnder5Film: true,
      lastWarnedFilmLevel: currentLevel,
    );
  }

  void setRibbonUnder2Sent(double currentLevel) {
    state = state.copyWith(
      isSentUnder2Ribbon: true,
      lastWarnedRibbonLevel: currentLevel,
    );
  }

  /// 2% 미만 필름 경고 전송 상태 설정
  void setFilmUnder2Sent(double currentLevel) {
    state = state.copyWith(
      isSentUnder2Film: true,
      lastWarnedFilmLevel: currentLevel,
    );
  }

  /// 모든 경고 상태 초기화
  void resetAllWarnings() {
    state = state.reset();
  }

  /// 특정 레벨의 경고 상태 초기화
  void resetWarningsForLevel(int level) {
    switch (level) {
      case 20:
        state = state.copyWith(
          isSentUnder20Ribbon: false,
          isSentUnder20Film: false,
        );
        break;
      case 10:
        state = state.copyWith(
          isSentUnder10Ribbon: false,
          isSentUnder10Film: false,
        );
        break;
      case 5:
        state = state.copyWith(
          isSentUnder5Ribbon: false,
          isSentUnder5Film: false,
        );
        break;
    }
  }

  /// 리본/필름 상태를 확인하고 필요시 경고 전송
  void checkAndSendWarnings(int machineId , RibbonStatus ribbonStatus) {
    _checkAndSendWarningsInternal(machineId, ribbonStatus);
  }

  /// 내부 로직 - 테스트에서 직접 호출 가능
  void _checkAndSendWarningsInternal(int machineId, dynamic ribbonStatus) {
    final ribbonLevel = ribbonStatus.rbnRemaining.toDouble();
    final filmLevel = ribbonStatus.filmRemaining.toDouble();

    // 보충 감지: 실제 잔량이 마지막 경고 잔량보다 증가했는지 확인
    final ribbonRefilled = ribbonLevel > state.lastWarnedRibbonLevel;
    final filmRefilled = filmLevel > state.lastWarnedFilmLevel;

    // 보충이 감지되면 해당 경고 상태들을 리셋
    if (ribbonRefilled) {
      state = state.copyWith(
        isSentUnder20Ribbon: false,
        isSentUnder10Ribbon: false,
        isSentUnder5Ribbon: false,
        lastWarnedRibbonLevel: ribbonLevel,
      );
    }

    if (filmRefilled) {
      state = state.copyWith(
        isSentUnder20Film: false,
        isSentUnder10Film: false,
        isSentUnder5Film: false,
        lastWarnedFilmLevel: filmLevel,
      );
    }

    // 각 레벨별로 독립적으로 경고 상태 확인
    // 2% 미만 체크 (가장 심각한 경고)
    if (ribbonLevel <= 2 && !state.isSentUnder2Ribbon) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId CRITICAL: Ribbon level is ${ribbonLevel.toInt()}% (under 2%), please replace immediately!');
      setRibbonUnder20Sent(ribbonLevel); // 5% 미만이므로 20% 경고도 함께 설정
      setRibbonUnder10Sent(ribbonLevel); // 5% 미만이므로 10% 경고도 함께 설정
      setRibbonUnder5Sent(ribbonLevel);
      setRibbonUnder2Sent(ribbonLevel);
    }

    if (filmLevel <= 2 && !state.isSentUnder2Film) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId CRITICAL: Film level is ${filmLevel.toInt()}% (under 2%), please replace immediately!');
      setFilmUnder20Sent(filmLevel); // 5% 미만이므로 20% 경고도 함께 설정
      setFilmUnder10Sent(filmLevel); // 5% 미만이므로 10% 경고도 함께 설정
      setFilmUnder5Sent(filmLevel);    
      setFilmUnder2Sent(filmLevel);
    }

    // 5% 미만 체크
    if (ribbonLevel <= 5 && !state.isSentUnder5Ribbon) {
      SlackLogService().sendRibbonFilmWarningLog(
          'MachineId : $machineId CRITICAL: Ribbon level is ${ribbonLevel.toInt()}% (under 5%), please replace immediately!');
      setRibbonUnder20Sent(ribbonLevel); // 5% 미만이므로 20% 경고도 함께 설정
      setRibbonUnder10Sent(ribbonLevel); // 5% 미만이므로 10% 경고도 함께 설정
      setRibbonUnder5Sent(ribbonLevel);
    }

    if (filmLevel <= 5 && !state.isSentUnder5Film) {
      SlackLogService().sendRibbonFilmWarningLog(
          'MachineId : $machineId CRITICAL: Film level is ${filmLevel.toInt()}% (under 5%), please replace immediately!');
      setFilmUnder20Sent(filmLevel); // 5% 미만이므로 20% 경고도 함께 설정
      setFilmUnder10Sent(filmLevel); // 5% 미만이므로 10% 경고도 함께 설정
      setFilmUnder5Sent(filmLevel);
    }

    // 10% 미만 체크 (5% 경고와 독립적으로 실행)
    if (ribbonLevel <= 10 && !state.isSentUnder10Ribbon) {
      SlackLogService().sendRibbonFilmWarningLog(
          'MachineId : $machineId WARNING: Ribbon level is ${ribbonLevel.toInt()}% (under 10%), please check the printer');
      setRibbonUnder20Sent(ribbonLevel); // 10% 미만이므로 20% 경고도 함께 설정
      setRibbonUnder10Sent(ribbonLevel);
    }

    if (filmLevel <= 10 && !state.isSentUnder10Film) {
      SlackLogService().sendRibbonFilmWarningLog(
          'MachineId : $machineId WARNING: Film level is ${filmLevel.toInt()}% (under 10%), please check the printer');
      setFilmUnder20Sent(filmLevel); // 10% 미만이므로 20% 경고도 함께 설정
      setFilmUnder10Sent(filmLevel);
    }

    // 20% 미만 체크 (다른 경고와 독립적으로 실행)
    if (ribbonLevel <= 20 && !state.isSentUnder20Ribbon) {
      SlackLogService().sendRibbonFilmWarningLog(
          'MachineId : $machineId INFO: Ribbon level is ${ribbonLevel.toInt()}% (under 20%), please check the printer');
      setRibbonUnder20Sent(ribbonLevel);
    }

    if (filmLevel <= 20 && !state.isSentUnder20Film) {
      SlackLogService().sendRibbonFilmWarningLog(
          'MachineId : $machineId INFO: Film level is ${filmLevel.toInt()}% (under 20%), please check the printer');
      setFilmUnder20Sent(filmLevel);
    }

  }

  bool isRibbonShouldBeChanged(RibbonStatus ribbonStatus) {
    final ribbonLevel = ribbonStatus.rbnRemaining.toDouble();
    return ribbonLevel < 2;
  }

  bool isFilmShouldBeChanged(RibbonStatus ribbonStatus) {
    final filmLevel = ribbonStatus.filmRemaining.toDouble();
    return filmLevel < 2;
  }

  bool isBothRibbonAndFilmShouldBeChanged(RibbonStatus ribbonStatus) {
    final ribbonLevel = ribbonStatus.rbnRemaining.toDouble();
    final filmLevel = ribbonStatus.filmRemaining.toDouble();

    return ribbonLevel < 2 && filmLevel < 2;
  }
}

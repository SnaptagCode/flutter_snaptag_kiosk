import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

part 'ribbon_warning_provider.g.dart';

/// 리본/필름 경고 상태를 관리하는 클래스
class RibbonWarningState {
  final bool isSentUnder20Ribbon;
  final bool isSentUnder20Film;
  final bool isSentUnder10Ribbon;
  final bool isSentUnder10Film;
  final bool isSentUnder5Ribbon;
  final bool isSentUnder5Film;

  const RibbonWarningState({
    this.isSentUnder20Ribbon = false,
    this.isSentUnder20Film = false,
    this.isSentUnder10Ribbon = false,
    this.isSentUnder10Film = false,
    this.isSentUnder5Ribbon = false,
    this.isSentUnder5Film = false,
  });

  RibbonWarningState copyWith({
    bool? isSentUnder20Ribbon,
    bool? isSentUnder20Film,
    bool? isSentUnder10Ribbon,
    bool? isSentUnder10Film,
    bool? isSentUnder5Ribbon,
    bool? isSentUnder5Film,
  }) {
    return RibbonWarningState(
      isSentUnder20Ribbon: isSentUnder20Ribbon ?? this.isSentUnder20Ribbon,
      isSentUnder20Film: isSentUnder20Film ?? this.isSentUnder20Film,
      isSentUnder10Ribbon: isSentUnder10Ribbon ?? this.isSentUnder10Ribbon,
      isSentUnder10Film: isSentUnder10Film ?? this.isSentUnder10Film,
      isSentUnder5Ribbon: isSentUnder5Ribbon ?? this.isSentUnder5Ribbon,
      isSentUnder5Film: isSentUnder5Film ?? this.isSentUnder5Film,
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
  void setRibbonUnder20Sent() {
    state = state.copyWith(isSentUnder20Ribbon: true);
  }

  /// 20% 미만 필름 경고 전송 상태 설정
  void setFilmUnder20Sent() {
    state = state.copyWith(isSentUnder20Film: true);
  }

  /// 10% 미만 리본 경고 전송 상태 설정
  void setRibbonUnder10Sent() {
    state = state.copyWith(isSentUnder10Ribbon: true);
  }

  /// 10% 미만 필름 경고 전송 상태 설정
  void setFilmUnder10Sent() {
    state = state.copyWith(isSentUnder10Film: true);
  }

  /// 5% 미만 리본 경고 전송 상태 설정
  void setRibbonUnder5Sent() {
    state = state.copyWith(isSentUnder5Ribbon: true);
  }

  /// 5% 미만 필름 경고 전송 상태 설정
  void setFilmUnder5Sent() {
    state = state.copyWith(isSentUnder5Film: true);
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
  void checkAndSendWarnings(WidgetRef ref) {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    final ribbonStatus = ref.read(printerServiceProvider.notifier).getRibbonStatus();
    
    final ribbonLevel = ribbonStatus.rbnRemaining;
    final filmLevel = ribbonStatus.filmRemaining;

    // 리본과 필름 레벨이 모두 30% 이상인 경우 경고 초기화
    if (ribbonLevel > 30 && filmLevel > 30) {
      resetAllWarnings();
      return;
    }
    
    // 각 레벨별로 독립적으로 경고 상태 확인
    // 5% 미만 체크 (가장 심각한 경고)
    if (ribbonLevel <= 5 && !state.isSentUnder5Ribbon) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId CRITICAL: Ribbon level is $ribbonLevel% (under 5%), please replace immediately!');
      setRibbonUnder5Sent();
    }

    if (filmLevel <= 5 && !state.isSentUnder5Film) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId CRITICAL: Film level is $filmLevel% (under 5%), please replace immediately!');
      setFilmUnder5Sent();
    }

    // 10% 미만 체크 (5% 경고와 독립적으로 실행)
    if (ribbonLevel <= 10 && !state.isSentUnder10Ribbon) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId WARNING: Ribbon level is $ribbonLevel% (under 10%), please check the printer');
      setRibbonUnder10Sent();
    }

    if (filmLevel <= 10 && !state.isSentUnder10Film) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId WARNING: Film level is $filmLevel% (under 10%), please check the printer');
      setFilmUnder10Sent();
    }

    // 20% 미만 체크 (다른 경고와 독립적으로 실행)
    if (ribbonLevel <= 20 && !state.isSentUnder20Ribbon) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId INFO: Ribbon level is $ribbonLevel% (under 20%), please check the printer');
      setRibbonUnder20Sent();
    }

    if (filmLevel <= 20 && !state.isSentUnder20Film) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId INFO: Film level is $filmLevel% (under 20%), please check the printer');
      setFilmUnder20Sent();
    }

    // 둘 다 동시에 낮은 경우 추가 경고 (각 레벨별로 체크)
    if (ribbonLevel <= 5 && filmLevel <= 5 && 
        !state.isSentUnder5Ribbon && !state.isSentUnder5Film) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId EMERGENCY: Both Ribbon ($ribbonLevel%) and Film ($filmLevel%) are under 5%! Immediate replacement required!');
    } else if (ribbonLevel <= 10 && filmLevel <= 10 && 
               !state.isSentUnder10Ribbon && !state.isSentUnder10Film) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId WARNING: Both Ribbon ($ribbonLevel%) and Film ($filmLevel%) are under 10%! Please check the printer');
    } else if (ribbonLevel <= 20 && filmLevel <= 20 && 
               !state.isSentUnder20Ribbon && !state.isSentUnder20Film) {
      SlackLogService().sendErrorLogToSlack(
          'MachineId : $machineId INFO: Both Ribbon ($ribbonLevel%) and Film ($filmLevel%) are under 20%! Please check the printer');
    }
  }
}
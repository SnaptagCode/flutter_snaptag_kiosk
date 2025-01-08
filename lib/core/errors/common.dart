enum KioskErrorType {
  missingMachineId('키오스크 ID가 설정되지 않았습니다.\n다음 경로의 설정 파일을 확인해주세요'),
  missingEventId('이벤트 ID가 설정되지 않았습니다.\n다음 경로의 설정 파일을 확인해주세요');

  final String value;

  const KioskErrorType(this.value);
}

class KioskException implements Exception {
  final KioskErrorType type;

  KioskException(this.type);
}

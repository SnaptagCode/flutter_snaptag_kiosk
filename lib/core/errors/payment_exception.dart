class PaymentException implements Exception {
  const PaymentException(this.type);
  final PaymentExceptionType type;

  @override
  String toString() => 'PaymentException: ${type.message}';
}

enum PaymentExceptionType {
  normalCompletion(0000, '정상완료'),
  businessNumberError(6001, '사업자번호 오류'),
  socialSecurityNumberError(6002, '주민등록번호 오류'),
  passwordError(6003, '비밀번호 오류'),
  authTransactionNotRegistered(6004, '인증거래미약정 가맹점'),
  ssnPasswordError(6005, '주민등록번호 + 비밀번호 오류'),
  futureServiceScheduled(6006, '(인증)추후서비스 예정'),
  passwordAttemptExceeded(6007, '비밀번호횟수초과'),
  idOrBusinessNumberError(6008, '주민번호 또는 사업자번호 오류'),
  cavvError(6011, 'CAVV 오류'),
  cavvTransactionCancelRequired(6012, 'CAVV 취소후 거래요망'),
  alreadyCancelled(7001, '이미 취소된 거래'),
  alreadyCollected(7002, '이미 매입된 거래'),
  noOriginalTransaction(7003, '원거래 없음'),
  notInstallmentMerchant(7570, '할부가맹점이 아님'),
  merchantLimitExceeded(7571, '가맹점 한도초과'),
  reQueryRequested(7803, '재 조회요망(KSVAN PROCESS ERROR)'),
  merchantTerminated(7978, '가맹점 해지'),
  unregisteredOrTerminatedMerchant(7979, '가맹점 미등록, 해지, 취소, 거래정지 가맹점'),
  notCreditCard(8000, '신용카드 아님'),
  amountError(8006, '거래금액 1,000원 미만, 또는 99,999,999이상 금액 오류'),
  noAmountEntered(8009, '거래금액 미입력'),
  installmentAmountError(8032, '할부금액 오류'),
  cardNumberInputError(8037, '카드번호 잘못입력 (Check Digit Error)'),
  dataFormatError(8038, 'Data Format 오류'),
  expiredCard(8314, '유효기간 경과카드'),
  transactionSuspendedCard(8324, '거래정지카드(B/L)'),
  stolenOrLostCard(8350, '도난, 분실카드'),
  callCardIssuer(8373, '카드사 전화요망'),
  generalError(8375, '기타 에러 처리'),
  cardIssuerTimeout(8380, '카드사장애 무응답 또는 지연응답시 (timeout)'),
  ksnetSystemError(8381, '전산장애 KSNET 전화요망'),
  unknown(-1, '알 수 없는 응답 코드');

  const PaymentExceptionType(this.code, this.message);
  final int code;
  final String message;

  static PaymentExceptionType fromCode(int code) {
    for (var response in PaymentExceptionType.values) {
      if (response.code == code) {
        return response;
      }
    }
    return PaymentExceptionType.unknown;
  }
}

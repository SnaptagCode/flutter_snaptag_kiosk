/// 환불 처리 결과. 원격(관리자) 환불과 자동환불이 공용으로 사용한다.
///
/// 성공/실패 판정은 프로젝트 표준인 `orderState == OrderStatus.refunded` 기준이며,
/// 실패 사유는 PG 원문 대신 사용자에게 보여줄 로케일 키로만 전달한다.
/// (PG 원문/상세 코드는 Slack 로그로만 남긴다.)
sealed class RefundResult {
  const RefundResult();
}

final class RefundSuccess extends RefundResult {
  final int amount;
  const RefundSuccess(this.amount);
}

final class RefundFailure extends RefundResult {
  /// 사용자에게 보여줄 안내 문구의 로케일 키. View에서 `.tr()`로 다국어 처리한다.
  /// (PG 원문 메시지는 사용자에게 노출하지 않고 Slack 로그로만 남긴다.)
  final String reasonKey;
  const RefundFailure(this.reasonKey);
}

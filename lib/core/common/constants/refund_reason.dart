import 'package:flutter_snaptag_kiosk/lib.dart';

/// 환불(취소) 응답코드 → 사람이 읽는 사유.
///
/// 구글시트 "KSCAT 응답코드 정리 > 환불관련" 탭을 seed로 한다.
/// 필요에 따라 이 Map에 줄만 추가/삭제하면 유동적으로 확장할 수 있다.
/// 미등록 코드는 [refundReasonFor]에서 "확인필요 (코드: XXXX)"로 표기되므로,
/// 로그에 뜬 코드를 보고 여기에 추가하면 된다.
/// 실패 사유용 매핑이므로 성공 코드('0000')는 넣지 않는다.
/// (성공 케이스는 refundReasonFor를 호출하지 않음)
const Map<String, String> kRefundReasonByCode = {
  // 1.신용(인증)
  '7001': '이미 취소된 거래',
  '7002': '이미 매입된 거래',
  '7003': '원거래 없음',
  '7803': '재조회 요망',
  '7978': '가맹점 해지',
  '7979': '가맹점 미등록/해지/거래정지',
  '8038': 'Data Format 오류',
  '8380': '카드사 장애 무응답/지연(timeout)',
  '8381': '전산장애(KSNET 문의)',
  '8555': '부분매입취소금액이 취소대상잔액보다 큼',
  '8556': '원거래 전체취소 시 부분매입취소내역 존재',
  // 5.KSCAT(F)
  '1000': '거래 취소됨(취소 버튼)',
  '1001': '전문 오류',
  '1002': '로그생성 실패',
  '1003': '이전거래 미완료',
  '1004': '시간 초과',
  '1099': '기타 오류',
};

/// 환불 실패 사유를 결정한다. (성공 케이스에는 호출하지 않는다.)
///
/// 우선순위: respCode 매핑 → res 매핑 → `확인필요 (코드: {코드})`.
/// PG 원문 메시지(MESSAGE1/2)는 사용하지 않는다.
String refundReasonFor(PaymentResponse? p) {
  if (p == null) return '확인필요';

  final respCode = p.respCode;
  if (respCode != null && respCode.isNotEmpty) {
    final byRespCode = kRefundReasonByCode[respCode];
    if (byRespCode != null) return byRespCode;
  }

  final byRes = kRefundReasonByCode[p.res];
  if (byRes != null) return byRes;

  final unknown = (respCode != null && respCode.isNotEmpty) ? respCode : p.res;
  return '확인필요 (코드: $unknown)';
}

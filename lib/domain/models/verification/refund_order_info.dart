class RefundOrderInfo {
  const RefundOrderInfo({
    this.orderId,
    this.authSeqNumber,
    this.completedAt,
  });

  final int? orderId;
  final String? authSeqNumber;
  final DateTime? completedAt;
}

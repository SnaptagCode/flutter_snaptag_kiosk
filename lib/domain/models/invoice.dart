class Invoice {
  int total;
  int supplyAmount;
  int taxAmount;

  Invoice._({required this.total, required this.supplyAmount, required this.taxAmount});
  factory Invoice.calculate(int total) {
    final supplyAmount = (total / 1.1).round();
    final taxAmount = total - supplyAmount;

    return Invoice._(
      total: total,
      supplyAmount: supplyAmount,
      taxAmount: taxAmount,
    );
  }
}

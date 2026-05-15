class GetOrdersParams {
  final int pageSize;
  final int currentPage;
  final int? kioskMachineId;

  const GetOrdersParams({
    required this.pageSize,
    required this.currentPage,
    this.kioskMachineId,
  });
}

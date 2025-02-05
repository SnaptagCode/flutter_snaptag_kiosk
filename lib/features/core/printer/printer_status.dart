class PrinterStatus {
  final int mainCode;
  final int subCode;
  final int mainStatus;
  final int errorStatus;
  final int warningStatus;
  final int chassisTemperature;
  final int printHeadTemperature;
  final int heaterTemperature;
  final int subStatus;

  const PrinterStatus({
    required this.mainCode,
    required this.subCode,
    required this.mainStatus,
    required this.errorStatus,
    required this.warningStatus,
    required this.chassisTemperature,
    required this.printHeadTemperature,
    required this.heaterTemperature,
    required this.subStatus,
  });
}

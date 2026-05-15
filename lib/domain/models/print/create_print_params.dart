class CreatePrintParams {
  final int kioskMachineId;
  final int kioskEventId;
  final int frontPhotoCardId;
  final int backPhotoCardId;
  final int kioskOrderId;

  const CreatePrintParams({
    required this.kioskMachineId,
    required this.kioskEventId,
    required this.frontPhotoCardId,
    required this.backPhotoCardId,
    required this.kioskOrderId,
  });
}

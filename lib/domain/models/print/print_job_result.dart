class PrintJobResult {
  final int kioskEventId;
  final int backPhotoId;
  final int printedPhotoCardId;
  final String formattedImageUrl;

  const PrintJobResult({
    required this.kioskEventId,
    required this.backPhotoId,
    required this.printedPhotoCardId,
    required this.formattedImageUrl,
  });
}

abstract interface class IIdWriterService {
  Future<void> writePhotocodeMeta({
    required String machineId,
    required String kioskEventId,
    required String cardCountInfo,
    required String serviceName,
    required String version,
  });
}

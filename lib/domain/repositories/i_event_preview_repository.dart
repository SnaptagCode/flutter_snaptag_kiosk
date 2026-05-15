abstract interface class IEventPreviewRepository {
  Future<void> createUniqueKeyHistory({
    required String machineId,
    required String uniqueKey,
  });
}

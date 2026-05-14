abstract interface class ISetupRepository {
  Future<void> deleteEndMark({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  });

  Future<void> endKioskApplication({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  });
}

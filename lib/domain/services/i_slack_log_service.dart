abstract interface class ISlackLogService {
  Future<void> sendLog(String message);
  Future<void> sendErrorLog(String message);
  Future<void> sendBroadcastLogWithKey(String key);
  Future<void> sendInspectionEndBroadcastLog(String key);
}

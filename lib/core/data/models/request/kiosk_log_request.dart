class KioskLogRequest {
  const KioskLogRequest._({
    required this.logId,
    required this.machineId,
    required this.title,
    required this.content,
  });

  final int logId;
  final int machineId;
  final String title;
  final String content;

  factory KioskLogRequest.withLogId({
    required int logId,
    required int machineId,
    required String title,
    required String content,
  }) =>
      KioskLogRequest._(logId: logId, machineId: machineId, title: title, content: content);
}

const String kHeartbeatScreenSetup = 'setup';
const String kHeartbeatScreenCustomer = 'customer';

const String kCustomerRoutePrefix = '/kiosk';

String screenForPath(String path) =>
    path == kCustomerRoutePrefix || path.startsWith('$kCustomerRoutePrefix/')
        ? kHeartbeatScreenCustomer
        : kHeartbeatScreenSetup;

const Duration kHeartbeatMaxAge = Duration(minutes: 15);

class HeartbeatNote {
  const HeartbeatNote({
    this.at,
    this.restartOnCrash,
    this.eventId,
    this.eventRunning,
    this.screen,
    this.printMode,
  });

  final DateTime? at;
  final bool? restartOnCrash;
  final String? eventId;
  final bool? eventRunning;
  final String? screen;
  final String? printMode;

  static HeartbeatNote? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    final at = json['at'];
    final eventId = json['eventId'];
    return HeartbeatNote(
      at: at is String ? DateTime.tryParse(at)?.toLocal() : null,
      restartOnCrash: json['restartOnCrash'] is bool ? json['restartOnCrash'] as bool : null,
      eventId: eventId == null ? null : '$eventId',
      eventRunning: json['eventRunning'] is bool ? json['eventRunning'] as bool : null,
      screen: json['screen'] is String ? json['screen'] as String : null,
      printMode: json['printMode'] is String ? json['printMode'] as String : null,
    );
  }
}

bool canRecoverEvent(
  HeartbeatNote? note, {
  required DateTime now,
  Duration maxAge = kHeartbeatMaxAge,
}) {
  final at = note?.at;
  if (at == null) return false;
  if (note!.restartOnCrash != true) return false;
  if (note.eventRunning != true) return false;
  if (note.screen != kHeartbeatScreenCustomer) return false;

  final elapsed = now.difference(at);
  if (elapsed.isNegative) return false;
  return elapsed < maxAge;
}

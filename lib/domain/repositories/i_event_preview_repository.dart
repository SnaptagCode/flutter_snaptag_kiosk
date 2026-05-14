import 'package:flutter_snaptag_kiosk/data/models/request/unique_key_request.dart';

abstract interface class IEventPreviewRepository {
  Future<void> createUniqueKeyHistory(UniqueKeyRequest request);
}

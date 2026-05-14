import 'package:flutter_snaptag_kiosk/data/models/request/unique_key_request.dart';

abstract interface class IEventPreviewRemoteDataSource {
  Future<void> createUniqueKeyHistory(UniqueKeyRequest request);
}

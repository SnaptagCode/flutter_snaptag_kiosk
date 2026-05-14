import 'package:flutter_snaptag_kiosk/core/data/models/request/unique_key_request.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/i_event_preview_remote_data_source.dart';

class EventPreviewRemoteDataSourceImpl implements IEventPreviewRemoteDataSource {
  final KioskApiClient _apiClient;

  EventPreviewRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> createUniqueKeyHistory(UniqueKeyRequest request) {
    return _apiClient.createUniqueKeyHistory(body: request.toJson());
  }
}

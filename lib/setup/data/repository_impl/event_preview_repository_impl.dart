import 'package:flutter_snaptag_kiosk/core/data/models/request/unique_key_request.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/i_event_preview_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/setup/domain/repository/i_event_preview_repository.dart';

class EventPreviewRepositoryImpl implements IEventPreviewRepository {
  final IEventPreviewRemoteDataSource _dataSource;

  EventPreviewRepositoryImpl(this._dataSource);

  @override
  Future<void> createUniqueKeyHistory(UniqueKeyRequest request) {
    return _dataSource.createUniqueKeyHistory(request);
  }
}

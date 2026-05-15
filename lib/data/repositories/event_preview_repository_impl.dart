import 'package:flutter_snaptag_kiosk/data/models/request/unique_key_request.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/i_event_preview_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_event_preview_repository.dart';

class EventPreviewRepositoryImpl implements IEventPreviewRepository {
  final IEventPreviewRemoteDataSource _dataSource;

  EventPreviewRepositoryImpl(this._dataSource);

  @override
  Future<void> createUniqueKeyHistory({
    required String machineId,
    required String uniqueKey,
  }) {
    return _dataSource.createUniqueKeyHistory(
      UniqueKeyRequest(machineId: machineId, uniqueKey: uniqueKey),
    );
  }
}

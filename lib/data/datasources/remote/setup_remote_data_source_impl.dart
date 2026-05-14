import 'package:flutter_snaptag_kiosk/data/datasources/remote/kiosk_api_client.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/i_setup_remote_data_source.dart';

class SetupRemoteDataSourceImpl implements ISetupRemoteDataSource {
  final KioskApiClient _apiClient;

  const SetupRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> deleteEndMark({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {
    await _apiClient.deleteEndMark(
      kioskEventId: kioskEventId,
      machineId: machineId,
      remainingSingleSidedCount: remainingSingleSidedCount,
    );
  }

  @override
  Future<void> endKioskApplication({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {
    await _apiClient.endKioskApplication(
      kioskEventId: kioskEventId,
      machineId: machineId,
      remainingSingleSidedCount: remainingSingleSidedCount,
    );
  }
}

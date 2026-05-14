import 'package:flutter_snaptag_kiosk/setup/data/data_source/i_setup_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_setup_repository.dart';

class SetupRepositoryImpl implements ISetupRepository {
  final ISetupRemoteDataSource _dataSource;

  const SetupRepositoryImpl(this._dataSource);

  @override
  Future<void> deleteEndMark({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {
    await _dataSource.deleteEndMark(
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
    await _dataSource.endKioskApplication(
      kioskEventId: kioskEventId,
      machineId: machineId,
      remainingSingleSidedCount: remainingSingleSidedCount,
    );
  }
}

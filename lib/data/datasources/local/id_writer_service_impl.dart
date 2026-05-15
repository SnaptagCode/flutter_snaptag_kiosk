import 'package:flutter_snaptag_kiosk/data/datasources/local/id_writer.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_id_writer_service.dart';

class IdWriterServiceImpl implements IIdWriterService {
  const IdWriterServiceImpl();

  @override
  Future<void> writePhotocodeMeta({
    required String machineId,
    required String kioskEventId,
    required String cardCountInfo,
    required String serviceName,
    required String version,
  }) {
    return writePhotocodeId(machineId, kioskEventId, cardCountInfo, serviceName, version);
  }
}

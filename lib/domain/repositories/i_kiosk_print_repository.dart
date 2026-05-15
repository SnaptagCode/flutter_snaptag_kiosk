import 'package:flutter_snaptag_kiosk/domain/models/print/create_print_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/print/print_job_result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/print/update_print_params.dart';

abstract interface class IKioskPrintRepository {
  Future<PrintJobResult> createPrintStatus({required CreatePrintParams params});
  Future<void> updatePrintStatus({
    required int printedPhotoCardId,
    required UpdatePrintParams params,
  });
}

import 'package:flutter_snaptag_kiosk/lib.dart';

class CheckPaymentDeviceUseCase {
  CheckPaymentDeviceUseCase(this._repository);

  final IPaymentRepository _repository;

  Future<KscatDeviceResponse> call() {
    return _repository.check();
  }
}

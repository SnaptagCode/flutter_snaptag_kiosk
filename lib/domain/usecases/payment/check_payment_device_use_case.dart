import 'package:flutter_snaptag_kiosk/domain/models/payment/device_check_result.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/usecase.dart';

class CheckPaymentDeviceUseCase implements NoParamsUseCase<DeviceCheckResult> {
  CheckPaymentDeviceUseCase(
    this._repository, {
    required int? kioskMachineId,
    required String? cardTerminalId,
  })  : _kioskMachineId = kioskMachineId,
        _cardTerminalId = cardTerminalId;

  final IPaymentRepository _repository;
  final int? _kioskMachineId;
  final String? _cardTerminalId;

  @override
  Future<DeviceCheckResult> call() {
    return _repository.check(
      kioskMachineId: _kioskMachineId,
      cardTerminalId: _cardTerminalId,
    );
  }
}

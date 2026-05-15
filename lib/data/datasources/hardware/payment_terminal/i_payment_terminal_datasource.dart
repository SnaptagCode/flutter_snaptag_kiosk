import 'package:flutter_snaptag_kiosk/data/models/models.dart';

abstract interface class IPaymentTerminalDatasource {
  Future<PaymentResponse> requestPayment(String callback, String request);
  Future<KscatDeviceResponse> requestDevice(String callback, String request);
}

import 'package:flutter_snaptag_kiosk/lib.dart';

abstract interface class IPaymentDatasource {
  Future<PaymentResponse> requestPayment(String callback, String request);
  Future<KscatDeviceResponse> requestDevice(String callback, String request);
}

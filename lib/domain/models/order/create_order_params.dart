import 'package:flutter_snaptag_kiosk/domain/models/enums/payment_type.dart';

class CreateOrderParams {
  final int kioskEventId;
  final int kioskMachineId;
  final String photoAuthNumber;
  final int amount;
  final PaymentType paymentType;
  final bool isSingleSided;

  const CreateOrderParams({
    required this.kioskEventId,
    required this.kioskMachineId,
    required this.photoAuthNumber,
    required this.amount,
    required this.paymentType,
    required this.isSingleSided,
  });
}

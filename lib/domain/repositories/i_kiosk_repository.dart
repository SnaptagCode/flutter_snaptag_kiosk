import 'package:flutter_snaptag_kiosk/domain/models/order/create_order_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_creation_result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/update_order_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';

abstract interface class IKioskRepository {
  Future<OrderCreationResult> createOrderStatus(CreateOrderParams params);
  Future<void> updateOrderStatus(int orderId, UpdateOrderParams params);
  Future<BackPhotoCard> getBackPhotoCardByQr({
    required int kioskEventId,
    required int nominatedBackPhotoCardId,
  });
}

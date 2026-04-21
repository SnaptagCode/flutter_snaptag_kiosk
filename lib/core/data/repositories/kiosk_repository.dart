import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/local/offline_config_service.dart';
import 'package:flutter_snaptag_kiosk/core/data/models/request/update_back_photo_request.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_repository.g.dart';

@riverpod
class KioskRepository extends _$KioskRepository {
  @override
  _KioskRepository build() => _KioskRepository(ref);
}

class _KioskRepository {
  final Ref _ref;

  _KioskRepository(this._ref);

  Future<String> healthCheck() async => 'ok';

  Future<void> sendSlackAlert(int machineId, String type, String text) async {}

  Future<List<AlertDefinitionResponse>> getAlertDefinition() async => [];

  Future<KioskMachineInfo> getKioskMachineInfo(int machineId) async =>
      _ref.read(offlineConfigServiceProvider).load();

  Future<KioskMachineInfo> getKioskMachineInfoByKey(String uniqueKey) async =>
      _ref.read(offlineConfigServiceProvider).load();

  Future<NominatedPhotoList> getFrontPhotoList(int eventId) async =>
      const NominatedPhotoList(list: []);

  Future<BackPhotoCardResponse> getBackPhotoCard(int eventId, String authNumber) async =>
      const BackPhotoCardResponse(
        kioskEventId: 0,
        backPhotoCardId: 0,
        nominatedBackPhotoCardId: 0,
        backPhotoCardOriginUrl: '',
        photoAuthNumber: '',
        embeddingProductId: 0,
        formattedBackPhotoCardUrl: '',
      );

  Future<BackPhotoStatusResponse> updateBackPhotoStatus(UpdateBackPhotoRequest request) async =>
      const BackPhotoStatusResponse(success: true);

  Future<OrderListResponse> getOrders(GetOrdersRequest request) async =>
      OrderListResponse(
        list: [],
        paging: PagingEntity(totalCount: 0, pageSize: 10, currentPage: 1, canNext: false),
      );

  Future<CreateOrderResponse> createOrderStatus(CreateOrderRequest request) async =>
      CreateOrderResponse(
        orderId: 1,
        kioskEventId: request.kioskEventId,
        kioskMachineId: request.kioskMachineId,
        backPhotoCardId: 0,
        amount: request.amount,
        status: OrderStatus.completed,
        paymentType: request.paymentType.name,
      );

  Future<UpdateOrderResponse> updateOrderStatus(int orderId, UpdateOrderRequest request) async =>
      UpdateOrderResponse(
        orderId: orderId,
        kioskEventId: request.kioskEventId,
        kioskMachineId: request.kioskMachineId,
        amount: request.amount.toDouble(),
        status: request.status,
        paymentType: PaymentType.free,
        kioskPaymentRecordId: 0,
      );

  Future<CreatePrintResponse> createPrintStatus({required CreatePrintRequest request}) async =>
      CreatePrintResponse(
        kioskEventId: request.kioskEventId,
        backPhotoId: request.backPhotoCardId,
        printedPhotoCardId: 1,
        formattedImageUrl: '',
      );

  Future<UpdatePrintResponse> updatePrintStatus({
    required int printedPhotoCardId,
    required UpdatePrintRequest request,
  }) async {
    return UpdatePrintResponse(
      kioskEventId: request.kioskEventId,
      status: request.status,
      printedPhotoCardId: printedPhotoCardId,
    );
  }

  Future<void> updatePrintLog({required dynamic request}) async {}

  Future<void> endKioskApplication({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {}

  Future<void> deleteEndMark({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {}

  Future<void> checkKioskAlive({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {}

  Future<void> createUniqueKeyHistory({required dynamic request}) async {}

  Future<BackPhotoCardResponse> getBackPhotoCardByQr(GetBackPhotoByQrRequest request) async =>
      const BackPhotoCardResponse(
        kioskEventId: 0,
        backPhotoCardId: 0,
        nominatedBackPhotoCardId: 0,
        backPhotoCardOriginUrl: '',
        photoAuthNumber: '',
        embeddingProductId: 0,
        formattedBackPhotoCardUrl: '',
      );
}

import 'package:flutter_snaptag_kiosk/data/datasources/remote/remote.dart';
import 'package:flutter_snaptag_kiosk/data/models/models.dart';
import 'package:flutter_snaptag_kiosk/flavors.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_repository.g.dart';

@riverpod
class KioskRepository extends _$KioskRepository {
  @override
  _KioskRepository build() {
    final dio = ref.watch(dioProvider(F.kioskBaseUrl));

    return _KioskRepository(KioskApiClient(dio));
  }
}

class _KioskRepository {
  final KioskApiClient _apiClient;

  _KioskRepository(this._apiClient);

  // Machine Info Operations
  Future<KioskMachineInfo> getKioskMachineInfo(int machineId) async {
    try {
      return await _apiClient.getKioskMachineInfo(kioskMachineId: machineId);
    } catch (e) {
      throw Exception(e);
    }
  }

  // Photo Operations
  Future<NominatedPhotoList> getFrontPhotoList(int eventId) async {
    try {
      return await _apiClient.getFrontPhotoList(kioskEventId: eventId);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BackPhotoCardResponse> getBackPhotoCard(int eventId, String authNumber) async {
    try {
      return await _apiClient.getBackPhotoCard(
        kioskEventId: eventId,
        photoAuthNumber: authNumber,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<OrderListResponse> getOrders(GetOrdersRequest request) async {
    try {
      return await _apiClient.getOrders(
        pageSize: request.pageSize,
        currentPage: request.currentPage,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CreateOrderResponse> createOrderStatus(CreateOrderRequest request) async {
    try {
      return await _apiClient.createOrder(
        body: request.toJson(),
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<UpdateOrderResponse> updateOrderStatus(int orderId, UpdateOrderRequest request) async {
    try {
      return await _apiClient.updateOrder(
        orderId: orderId,
        body: request.toJson(),
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CreatePrintResponse> createPrintStatus({
    required CreatePrintRequest request,
  }) async {
    try {
      return await _apiClient.createPrint(
        kioskMachineId: request.kioskMachineId,
        kioskEventId: request.kioskEventId,
        frontPhotoCardId: request.frontPhotoCardId,
        backPhotoCardId: request.backPhotoCardId,
        file: request.file,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<UpdatePrintResponse> updatePrintStatus({
    required int printedPhotoCardId,
    required UpdatePrintRequest request,
  }) async {
    try {
      return await _apiClient.updatePrint(
        printedPhotoCardId: printedPhotoCardId,
        body: request.toJson(),
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}

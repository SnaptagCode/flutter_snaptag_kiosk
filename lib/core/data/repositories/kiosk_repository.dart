import 'package:flutter_snaptag_kiosk/core/data/models/request/unique_key_request.dart';
import 'package:flutter_snaptag_kiosk/core/data/models/request/update_back_photo_request.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/printer_log.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/providers/card_count_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'kiosk_repository.g.dart';

@riverpod
class KioskRepository extends _$KioskRepository {
  @override
  _KioskRepository build() {
    final dio = ref.watch(dioProvider(F.kioskBaseUrl));

    return _KioskRepository(KioskApiClient(dio), ref);
  }
}

class _KioskRepository {
  final KioskApiClient _apiClient;
  final Ref _ref;

  _KioskRepository(this._apiClient, this._ref);
  Future<String> healthCheck() async {
    try {
      return await _apiClient.healthCheck();
    } catch (e) {
      rethrow;
    }
  }

  // Slack Alert definitions
  Future<List<AlertDefinitionResponse>> getAlertDefinition() async {
    try {
      return await _apiClient.getAlertDefinitions();
    } catch (e) {
      rethrow;
    }
  }

  // Machine Info Operations
  Future<KioskMachineInfo> getKioskMachineInfo(int machineId) async {
    try {
      return await _apiClient.getKioskMachineInfo(kioskMachineId: machineId);
    } catch (e) {
      rethrow;
    }
  }

  Future<KioskMachineInfo> getKioskMachineInfoByKey(String uniqueKey) async {
    try {
      return await _apiClient.getKioskMachineInfoByKey(uniqueKey: uniqueKey);
    } catch (e) {
      rethrow;
    }
  }

  // Photo Operations
  Future<NominatedPhotoList> getFrontPhotoList(int eventId) async {
    try {
      return await _apiClient.getFrontPhotoList(kioskEventId: eventId);
    } catch (e) {
      rethrow;
    }
  }

  Future<BackPhotoCardResponse> getBackPhotoCard(int eventId, String authNumber) async {
    try {
      return await _apiClient.getBackPhotoCard(
        kioskEventId: eventId,
        photoAuthNumber: authNumber,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BackPhotoStatusResponse> updateBackPhotoStatus(UpdateBackPhotoRequest request) async {
    try {
      return await _apiClient.updateBackPhotoStatus(
        body: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderListResponse> getOrders(GetOrdersRequest request) async {
    try {
      return await _apiClient.getOrders(
        pageSize: request.pageSize,
        currentPage: request.currentPage,
        kioskMachineId: request.kioskMachineId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateOrderResponse> createOrderStatus(CreateOrderRequest request) async {
    try {
      return await _apiClient.createOrder(
        body: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateOrderResponse> updateOrderStatus(int orderId, UpdateOrderRequest request) async {
    try {
      return await _apiClient.updateOrder(
        orderId: orderId,
        body: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CreatePrintResponse> createPrintStatus({
    required CreatePrintRequest request,
  }) async {
    try {
      return await _apiClient.createPrint(body: request.toJson());
    } catch (e) {
      rethrow;
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
      rethrow;
    }
  }

  Future<void> updatePrintLog({
    required PrinterLog request,
  }) async {
    try {
      final cardCount = _ref.read(cardCountProvider);

      await _apiClient.updatePrintLog(
        body: {
          ...request.toJson(),
          'remainingSingleSidedCount': cardCount.remainingSingleSidedCount,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> endKioskApplication({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {
    try {
      await _apiClient.endKioskApplication(
          kioskEventId: kioskEventId, machineId: machineId, remainingSingleSidedCount: remainingSingleSidedCount);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEndMark({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {
    try {
      await _apiClient.deleteEndMark(
          kioskEventId: kioskEventId, machineId: machineId, remainingSingleSidedCount: remainingSingleSidedCount);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkKioskAlive({
    required int kioskEventId,
    required int machineId,
    required String remainingSingleSidedCount,
  }) async {
    try {
      await _apiClient.checkKioskAlive(
          kioskEventId: kioskEventId, machineId: machineId, remainingSingleSidedCount: remainingSingleSidedCount);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUniqueKeyHistory({required UniqueKeyRequest request}) async {
    try {
      await _apiClient.createUniqueKeyHistory(body: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<BackPhotoCardResponse> getBackPhotoCardByQr(GetBackPhotoByQrRequest request) async {
    try {
      return await _apiClient.getBackPhotoCardByQr(
        body: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}

import 'dart:io';

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

  Future<UpdatePrintResponse> updatePrintedStatus({
    required int kioskMachineId,
    required int kioskEventId,
    required int frontPhotoCardId,
    required String photoAuthNumber,
    required PrintedStatus status,
    File? file,
    int? printedPhotoCardId,
  }) async {
    try {
      return await _apiClient.updatePrintedStatus(
        kioskMachineId: kioskMachineId,
        kioskEventId: kioskEventId,
        frontPhotoCardId: frontPhotoCardId,
        photoAuthNumber: photoAuthNumber,
        status: status,
        file: file,
        printedPhotoCardId: printedPhotoCardId,
      );
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

  Future<OrderResponse> createOrder(Map<String, dynamic> orderRequest) async {
    try {
      return await _apiClient.createOrder(
        request: CreateOrderRequest.fromJson(orderRequest),
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<OrderResponse> updateOrder(int orderId, OrderStatus status) async {
    try {
      return await _apiClient.updateOrder(
        orderId: orderId,
        request: UpdateOrderRequest(
          kioskEventId: 1,
          kioskMachineId: 1,
          photoAuthNumber: '1234',
          status: status,
          amount: 10000,
          purchaseAuthNumber: '1234',
          authSeqNumber: '1234',
          approvalNumber: '1234',
          detail: '1234',
        ), // JSON 변환
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<OrderResponse> getOrders(GetOrdersRequest request) async {
    try {
      return await _apiClient.getOrders(
        pageSize: request.pageSize,
        currentPage: request.currentPage,
        kioskEventId: request.kioskEventId,
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}

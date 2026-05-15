import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_snaptag_kiosk/data/models/request/unique_key_request.dart';
import 'package:flutter_snaptag_kiosk/data/models/request/update_back_photo_request.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/dio_client.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/kiosk_api_client.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/data/models/models.dart';
import 'package:flutter_snaptag_kiosk/domain/domain.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/create_order_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_creation_result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/update_order_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/print/create_print_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/print/print_job_result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/print/update_print_params.dart';
import 'package:flutter_snaptag_kiosk/flavors.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_repository.g.dart';

@riverpod
class KioskRepository extends _$KioskRepository {
  @override
  KioskRepositoryImpl build() {
    final dio = ref.watch(dioProvider(F.kioskBaseUrl));

    return KioskRepositoryImpl(KioskApiClient(dio));
  }
}

class KioskRepositoryImpl implements IKioskRepository, IKioskPrintRepository {
  final KioskApiClient _apiClient;

  KioskRepositoryImpl(this._apiClient);
  Future<String> healthCheck() async {
    try {
      return await _apiClient.healthCheck();
    } catch (e) {
      rethrow;
    }
  }

  /// POST /v1/internal/slack-alert — 서버가 타입·메시지에 따라 Slack 전송
  Future<void> sendSlackAlert(int machineId, String type, String text) async {
    try {
      await _apiClient.sendSlackAlert(machineId: machineId, body: {'type': type, 'text': text});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode >= 500) {
        // 서버 5xx 에러 시 슬랙 알림 없이 무시
        log('Slack 알림 전송 실패 (5xx 에러 무시): $statusCode');
        return;
      }
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

  @override
  Future<OrderCreationResult> createOrderStatus(CreateOrderParams params) async {
    final request = CreateOrderRequest(
      kioskEventId: params.kioskEventId,
      kioskMachineId: params.kioskMachineId,
      photoAuthNumber: params.photoAuthNumber,
      amount: params.amount,
      paymentType: params.paymentType,
      isSingleSided: params.isSingleSided,
    );
    try {
      final response = await _apiClient.createOrder(body: request.toJson());
      return response.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateOrderStatus(int orderId, UpdateOrderParams params) async {
    final request = UpdateOrderRequest(
      kioskEventId: params.kioskEventId,
      kioskMachineId: params.kioskMachineId,
      photoAuthNumber: params.photoAuthNumber,
      amount: params.photoCardPrice,
      status: params.approval?.orderState ?? (params.isRefund ? OrderStatus.refunded_failed : OrderStatus.failed),
      approvalNumber: params.approval?.approvalNo ?? '-',
      purchaseAuthNumber: params.approval?.approvalNo ?? '-',
      authSeqNumber: params.approval?.approvalNo ?? '-',
      detail: params.approval?.KSNET ?? '{}',
      description: params.description,
    );
    try {
      await _apiClient.updateOrder(orderId: orderId, body: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PrintJobResult> createPrintStatus({
    required CreatePrintParams params,
  }) async {
    final request = CreatePrintRequest(
      kioskMachineId: params.kioskMachineId,
      kioskEventId: params.kioskEventId,
      frontPhotoCardId: params.frontPhotoCardId,
      backPhotoCardId: params.backPhotoCardId,
      kioskOrderId: params.kioskOrderId,
    );
    try {
      final response = await _apiClient.createPrint(body: request.toJson());
      return response.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePrintStatus({
    required int printedPhotoCardId,
    required UpdatePrintParams params,
  }) async {
    final request = UpdatePrintRequest(
      kioskMachineId: params.kioskMachineId,
      kioskEventId: params.kioskEventId,
      status: params.status,
    );
    try {
      await _apiClient.updatePrint(
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
      await _apiClient.updatePrintLog(body: request.toJson());
    } catch (e) {
      SlackLogService().sendErrorLogToSlack('KioskRepository.updatePrintLog failure: $e');
      logger.e('KioskRepository.updatePrintLog failure', error: e);
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

  @override
  Future<BackPhotoCard> getBackPhotoCardByQr({
    required int kioskEventId,
    required int nominatedBackPhotoCardId,
  }) async {
    try {
      final response = await _apiClient.getBackPhotoCardByQr(
        body: GetBackPhotoByQrRequest(
          kioskEventId: kioskEventId,
          nominatedBackPhotoCardId: nominatedBackPhotoCardId,
        ).toJson(),
      );
      return response.toDomain();
    } catch (e) {
      rethrow;
    }
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_snaptag_kiosk/models/response/models.dart';
import 'package:retrofit/retrofit.dart';

part 'kiosk_api_client.g.dart';

@RestApi()
abstract class KioskApiClient {
  factory KioskApiClient(Dio dio, {String baseUrl}) = _KioskApiClient;

  // Health Check
  @GET('/v1/health-check')
  Future<void> healthCheck();

  // Machine APIs
  @GET('/v1/machine/info')
  Future<KioskMachineInfo> getKioskMachineInfo({
    @Query('kioskMachineId') required int kioskMachineId,
  });

  @PATCH('/v1/machine/print')
  @MultiPart()
  Future<UpdatePrintResponse> updatePrintStatus({
    @Part() required int kioskMachineId,
    @Part() required int kioskEventId,
    @Part() required int frontPhotoCardId,
    @Part() required String photoAuthNumber,
    @Part() required PrintStatus status,
    @Part() File? file,
    @Part() int? printedPhotoCardId,
  });

  // Event APIs
  @GET('/v1/kiosk-event/front-photo-list')
  Future<NominatedPhotoList> getFrontPhotoList({
    @Query('kioskEventId') required int kioskEventId,
  });

  @GET('/v1/kiosk-event/back-photo')
  Future<BackPhotoCardResponse> getBackPhotoCard({
    @Query('kioskEventId') required int kioskEventId,
    @Query('photoAuthNumber') required String photoAuthNumber,
  });

  @POST('/v1/order')
  Future<OrderResponse> createOrder({
    @Body() required CreateOrderRequest request,
  });

  @PATCH('/v1/order/{orderId}')
  Future<OrderResponse> updateOrder({
    @Path('orderId') required int orderId,
    @Body() required UpdateOrderRequest request,
  });
}

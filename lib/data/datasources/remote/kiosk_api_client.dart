import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
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

  @GET('/v1/kiosk-event/front-photo-list')
  Future<NominatedPhotoList> getFrontPhotoList({
    @Query('kioskEventId') required int kioskEventId,
  });

  @GET('/v1/kiosk-event/back-photo')
  Future<BackPhotoCardResponse> getBackPhotoCard({
    @Query('kioskEventId') required int kioskEventId,
    @Query('photoAuthNumber') required String photoAuthNumber,
  });

  @GET('/v1/order/list')
  Future<OrderListResponse> getOrders({
    @Query('pageSize') required int pageSize,
    @Query('currentPage') required int currentPage,
  });

  @POST('/v1/order')
  Future<CreateOrderResponse> createOrder({
    @Body() required Map<String, dynamic> body,
  });

  @PATCH('/v1/order/{orderId}')
  Future<UpdateOrderResponse> updateOrder({
    @Path('orderId') required int orderId,
    @Body() required Map<String, dynamic> body,
  });

  @POST('/v1/print')
  @MultiPart()
  Future<CreatePrintResponse> createPrint({
    @Part(name: 'kioskMachineId') required int kioskMachineId,
    @Part(name: 'kioskEventId') required int kioskEventId,
    @Part(name: 'frontPhotoCardId') required int frontPhotoCardId,
    @Part(name: 'backPhotoCardId') required int backPhotoCardId,
    @Part(name: 'file') File? file,
  });

  @PATCH('/v1/print/{printedPhotoCardId}')
  Future<UpdatePrintResponse> updatePrint({
    @Path('printedPhotoCardId') required int printedPhotoCardId,
    @Body() required Map<String, dynamic> body,
  });
}

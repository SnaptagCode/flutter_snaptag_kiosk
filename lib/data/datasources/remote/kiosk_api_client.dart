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
  Future<OrderResponse> getOrders({
    @Query('pageSize') required int pageSize,
    @Query('currentPage') required int currentPage,
    @Query('kioskEventId') required int kioskEventId,
  });

  @POST('/v1/order')
  Future<PostOrderResponse> createOrder({
    @Queries() required Map<String, dynamic> queries,
  });

  @PATCH('/v1/order/{orderId}')
  Future<PatchOrderResponse> updateOrder({
    @Path('orderId') required int orderId,
    @Queries() required Map<String, dynamic> queries,
  });
  @POST('/v1/print')
  @MultiPart()
  Future<PostPrintResponse> postPrint({
    @Part() required int kioskMachineId,
    @Part() required int kioskEventId,
    @Part() required int frontPhotoCardId,
    @Part() required String photoAuthNumber,
    @Part() required PrintedStatus status,
    @Part() File? file,
    @Part() int? printedPhotoCardId,
  });
  @PATCH('/v1/print/{printedPhotoCardId}')
  @MultiPart()
  Future<PatchPrintResponse> patchPrint({
    @Part() required int kioskMachineId,
    @Part() required int kioskEventId,
    @Part() required int frontPhotoCardId,
    @Part() required String photoAuthNumber,
    @Part() required PrintedStatus status,
    @Part() File? file,
    @Part() int? printedPhotoCardId,
  });
}

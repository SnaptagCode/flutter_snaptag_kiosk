import 'package:dio/dio.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:retrofit/retrofit.dart';

part 'kiosk_api_client.g.dart';

@RestApi()
abstract class KioskApiClient {
  factory KioskApiClient(Dio dio, {String baseUrl}) = _KioskApiClient;

  // Health Check
  @GET('/v1/health-check')
  Future<String> healthCheck();

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

  @POST('/v1/kiosk-event/update-back-photo-status')
  Future<BackPhotoStatusResponse> updateBackPhotoStatus({
    @Body() required Map<String, dynamic> body,
  });

  @GET('/v1/order/list')
  Future<OrderListResponse> getOrders({
    @Query('pageSize') required int pageSize,
    @Query('currentPage') required int currentPage,
    @Query('kioskMachineId') int? kioskMachineId,
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
  Future<CreatePrintResponse> createPrint({
    @Body() required Map<String, dynamic> body,
  });

  @PATCH('/v1/print/{printedPhotoCardId}')
  Future<UpdatePrintResponse> updatePrint({
    @Path('printedPhotoCardId') required int printedPhotoCardId,
    @Body() required Map<String, dynamic> body,
  });

  @POST('/v1/machine/log')
  Future<void> updatePrintLog({
    @Body() required Map<String, dynamic> body,
  });

  @GET('/v1/error-code')
  Future<List<AlertDefinitionResponse>> getAlertDefinitions();

  @POST('/v1/internal/event/{kioskEventId}/machine/{machineId}/end')
  Future<void> endKioskApplication(
      {@Path('kioskEventId') required int kioskEventId,
      @Path('machineId') required int machineId,
      @Query('remainingSingleSidedCount') required String remainingSingleSidedCount});

  @DELETE('/v1/internal/event/{kioskEventId}/machine/{machineId}/end')
  Future<void> deleteEndMark(
      {@Path('kioskEventId') required int kioskEventId,
      @Path('machineId') required int machineId,
      @Path('remainingSingleSidedCount') required String remainingSingleSidedCount});

  @POST('/v1/internal/event/check/{kioskEventId}/{machineId}')
  Future<void> checkKioskAlive(
      {@Path('kioskEventId') required int kioskEventId,
      @Path('machineId') required int machineId,
      @Query('remainingSingleSidedCount') required String remainingSingleSidedCount});

  @GET('/v1/intro/common-data')
  Future<List<IntroCommonData>> getIntroCommonData();
}

import 'kiosk_machine_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'info_response.freezed.dart';
part 'info_response.g.dart';

@freezed
class InfoResponse with _$InfoResponse {
  const factory InfoResponse({
    @Default(0) int kioskEventId,
    @Default(0) int kioskMachineId,
    @Default('') String kioskMachineName,
    @Default('') String kioskMachineDescription,
    @Default(0) int photoCardPrice,
    @Default('') String eventType,
    @Default('') String printedEventName,
    @Default('') String topBannerUrl,
    @Default('') String mainImageUrl,
    @Default('#000000') String mainButtonColor,
    @Default('#FFFFFF') String buttonTextColor,
    @Default('#CCCCCC') String keyPadColor,
    @Default('#000000') String couponTextColor,
    @Default('#000000') String mainTextColor,
    @Default('#000000') String popupButtonColor,
  }) = _InfoResponse;

  factory InfoResponse.fromJson(Map<String, dynamic> json) => _$InfoResponseFromJson(json);
}

extension InfoResponseExtension on InfoResponse {
  KioskMachineInfo toKioskMachineInfo() {
    return KioskMachineInfo(
      kioskEventId: kioskEventId,
      kioskMachineId: kioskMachineId,
      kioskMachineName: kioskMachineName,
      kioskMachineDescription: kioskMachineDescription,
      photoCardPrice: photoCardPrice,
      eventType: eventType,
      printedEventName: printedEventName,
      topBannerUrl: topBannerUrl,
      mainImageUrl: mainImageUrl,
      mainButtonColor: mainButtonColor,
      buttonTextColor: buttonTextColor,
      keyPadColor: keyPadColor,
      couponTextColor: couponTextColor,
      mainTextColor: mainTextColor,
      popupButtonColor: popupButtonColor,
    );
  }
}

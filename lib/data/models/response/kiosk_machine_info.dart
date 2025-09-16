import 'package:freezed_annotation/freezed_annotation.dart';

part 'kiosk_machine_info.freezed.dart';
part 'kiosk_machine_info.g.dart';

@freezed
class KioskMachineInfo with _$KioskMachineInfo {
  const factory KioskMachineInfo({
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
    @Default(false) bool isMetal,
  }) = _KioskMachineInfo;

  factory KioskMachineInfo.fromJson(Map<String, dynamic> json) => _$KioskMachineInfoFromJson(json);
}

extension KioskMachineInfoX on KioskMachineInfo {
  bool get isSuwon => kioskMachineId == 2 || kioskMachineId == 3;
}

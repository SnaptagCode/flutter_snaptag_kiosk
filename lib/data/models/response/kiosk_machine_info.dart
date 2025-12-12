import 'package:flutter_snaptag_kiosk/data/models/response/nominated_back_photo_card.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'event_video.dart';

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
    @Default('') String cardMetalType,
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
    @Default([]) List<EventVideo> eventVideos,
    @Default([]) List<NominatedBackPhotoCard> nominatedBackPhotoCardList,
    @Default('') String defaultCustomBackPhotoCard,
  }) = _KioskMachineInfo;

  factory KioskMachineInfo.fromJson(Map<String, dynamic> json) => _$KioskMachineInfoFromJson(json);
}

extension KioskMachineInfoX on KioskMachineInfo {
  bool get isSuwon => kioskMachineId == 2 || kioskMachineId == 3;
}

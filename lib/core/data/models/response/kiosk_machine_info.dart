import 'package:flutter_snaptag_kiosk/core/data/models/response/nominated_back_photo_card.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'event_video.dart';

part 'kiosk_machine_info.freezed.dart';
part 'kiosk_machine_info.g.dart';

@freezed
abstract class KioskMachineInfo with _$KioskMachineInfo {
  const factory KioskMachineInfo({
    @Default(0) int kioskEventId,
    @Default(0) int kioskMachineId,
    @Default(null) String? cardTerminalId,
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
    @Default('#000000') String keyPadTextColor,
    @Default('#000000') String couponTextColor,
    @Default('#000000') String mainTextColor,
    @Default('#000000') String popupButtonColor,
    @Default('#000000') String progressBarStartColor,
    @Default('#000000') String progressBarEndColor,
    @Default(false) bool isMetal,
    @Default([]) List<EventVideo> eventVideos,
    @Default([]) List<NominatedBackPhotoCard> nominatedBackPhotoCardList,
    @Default('') String emblemImageUrl,
    @Default('RANDOM') String frontPhotoType,
  }) = _KioskMachineInfo;

  factory KioskMachineInfo.fromJson(Map<String, dynamic> json) => _$KioskMachineInfoFromJson(json);
}

extension KioskMachineInfoX on KioskMachineInfo {
  bool get isSuwon => kioskMachineId == 2 || kioskMachineId == 3;
  bool get isHwe => eventType == 'HWEG';

  /// 앞면 이미지 선택형 이벤트 여부 (JKLI-175). 미지정/구버전 서버는 RANDOM(기존 랜덤 동작)
  bool get isFrontPhotoUserSelect => frontPhotoType == 'USER_SELECT';
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_machine_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KioskMachineInfoImpl _$$KioskMachineInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$KioskMachineInfoImpl(
      kioskEventId: (json['kioskEventId'] as num?)?.toInt() ?? 0,
      kioskMachineId: (json['kioskMachineId'] as num?)?.toInt() ?? 0,
      kioskMachineName: json['kioskMachineName'] as String? ?? '',
      kioskMachineDescription: json['kioskMachineDescription'] as String? ?? '',
      photoCardPrice: (json['photoCardPrice'] as num?)?.toInt() ?? 0,
      printedEventName: json['printedEventName'] as String? ?? '',
      topBannerUrl: json['topBannerUrl'] as String? ?? '',
      mainImageUrl: json['mainImageUrl'] as String? ?? '',
      mainButtonColor: json['mainButtonColor'] as String? ?? '#FF0000',
      buttonTextColor: json['buttonTextColor'] as String? ?? '#FFFFFF',
      couponTextColor: json['couponTextColor'] as String? ?? '#000000',
      mainTextColor: json['mainTextColor'] as String? ?? '#000000',
      popupButtonColor: json['popupButtonColor'] as String? ?? '#0000FF',
      keyPadColor: json['keyPadColor'] as String? ?? '#CCCCCC',
    );

Map<String, dynamic> _$$KioskMachineInfoImplToJson(
        _$KioskMachineInfoImpl instance) =>
    <String, dynamic>{
      'kioskEventId': instance.kioskEventId,
      'kioskMachineId': instance.kioskMachineId,
      'kioskMachineName': instance.kioskMachineName,
      'kioskMachineDescription': instance.kioskMachineDescription,
      'photoCardPrice': instance.photoCardPrice,
      'printedEventName': instance.printedEventName,
      'topBannerUrl': instance.topBannerUrl,
      'mainImageUrl': instance.mainImageUrl,
      'mainButtonColor': instance.mainButtonColor,
      'buttonTextColor': instance.buttonTextColor,
      'couponTextColor': instance.couponTextColor,
      'mainTextColor': instance.mainTextColor,
      'popupButtonColor': instance.popupButtonColor,
      'keyPadColor': instance.keyPadColor,
    };

import 'package:flutter_snaptag_kiosk/core/data/models/response/kiosk_machine_info.dart';

class SlackLogTemplate {
  final String key;
  final String category;
  final String title;
  final String serviceName;
  final String appVersion;
  final String description;
  final KioskMachineInfo? kioskMachineInfo;
  final String? guideText;
  final String? guideUrl;

  const SlackLogTemplate({
    required this.key,
    required this.category,
    required this.title,
    required this.serviceName,
    required this.appVersion,
    required this.description,
    this.kioskMachineInfo,
    this.guideText,
    this.guideUrl,
  });

  SlackLogTemplate copyWith({
    String? category,
    String? title,
    String? serviceName,
    String? kioskId,
    String? appVersion,
    String? description,
    String? guideText,
    String? guideUrl,
    KioskMachineInfo? kioskMachineInfo,
  }) {
    return SlackLogTemplate(
        key: key,
        category: category ?? this.category,
        title: title ?? this.title,
        serviceName: serviceName ?? this.serviceName,
        appVersion: appVersion ?? this.appVersion,
        description: description ?? this.description,
        guideText: guideText ?? this.guideText,
        guideUrl: guideUrl ?? this.guideUrl,
        kioskMachineInfo: kioskMachineInfo ?? this.kioskMachineInfo);
  }
}

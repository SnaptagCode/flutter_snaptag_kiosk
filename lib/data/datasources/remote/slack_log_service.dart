import 'dart:convert';
import 'dart:developer';

import 'package:flutter_snaptag_kiosk/data/models/entities/slack_log_template.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:flutter_snaptag_kiosk/core/providers/version_notifier.dart';

class SlackLogService {
  static final SlackLogService _instance = SlackLogService._internal();
  factory SlackLogService() => _instance;
  SlackLogService._internal();

  late ProviderContainer _container;

  final slackWebhookUrl = dotenv.env['SLACK_WEBHOOK_URL'];

  final slackWebhookErrorUrl = dotenv.env['SLACK_WEBHOOK_ERROR_LOG_URL'];

  final slackWebhookRibbonFilmWarnUrl = dotenv.env['SLACK_WEBHOOK_RIBBON_FILM_WARN_URL'];

  final slackWebhookWarningUrl = dotenv.env['SLACK_WEBHOOK_WARNING_URL'];

  final slackWebhookBroadcastUrl = dotenv.env['SLACK_WEBHOOK_BROADCAST_URL'];

  void init(ProviderContainer container) {
    _container = container;
    sendLogToSlack("🚀 Flutter App Started!");
  }

  Future<void> sendErrorLogToSlack(String message) async {
    await sendLog(slackWebhookErrorUrl, message);
  }

  Future<void> sendLogToSlack(String message) async {
    await sendLog(slackWebhookUrl, message);
  }

  Future<void> sendRibbonFilmWarningLog(String message) async {
    await sendLog(slackWebhookRibbonFilmWarnUrl, message);
  }

  Future<void> sendWarningLogToSlack(String message) async {
    await sendLog(slackWebhookWarningUrl, message);
  }

  // 1) 객체 만드는 함수 LogState
  // 2) 분기 처리 하는 함수 key, LogState. 결제 sendBraas
  // 3) buildSlackAlertMessage 실행 LogState

  Future<SlackLogTemplate> createSlackLogTemplate(
    String? errorKey,
  ) async {
    final definitions = _container.read(alertDefinitionProvider);
    final def = definitions.firstWhereOrNull((e) => e.key == errorKey);
    final kioskInfo = _container.read(kioskInfoServiceProvider);
    final version = _container.read(versionStateProvider).currentVersion;
    final eventType = kioskInfo?.eventType ?? "-";

    final serviceNameMap = {"SUF": "수원FC", "SEF": "서울 이랜드 FC", "KEEFO": "성수 B'Day", "AGFC": "안산그리너스FC"};

    final serviceName = serviceNameMap[eventType] ?? '-';

    return def != null && errorKey != null
        ? SlackLogTemplate(
            key: errorKey,
            category: def.category,
            title: def.title,
            serviceName: serviceName,
            appVersion: version,
            description: def.description,
            kioskMachineInfo: kioskInfo)
        : SlackLogTemplate(
            key: '',
            category: '',
            title: '',
            serviceName: serviceName,
            appVersion: version,
            description: '',
            kioskMachineInfo: kioskInfo);
  }

  Future<void> sendInspectionEndBroadcastLogToSlack(String errorKey, {required bool isPaymentOn}) async {
    final slackLogTemplate = await createSlackLogTemplate(errorKey);
    final cardCount = _container.read(cardCountProvider);

    if (slackLogTemplate.category.isNotEmpty) {
      final kioskInfo = slackLogTemplate.kioskMachineInfo;
      final eventName = kioskInfo?.printedEventName ?? "-";
      final printLog = _container.read(printerLogProvider);
      final printerheadTemp = printLog?.heaterTemperature ?? 0;
      final printerheadTempString = printerheadTemp != 0 ? (printerheadTemp / 100).toStringAsFixed(2) : "알 수 없음";

      String description;

      description = '''
${slackLogTemplate.description}

- 단면 카드 수량 : ${cardCount.currentCount} / ${cardCount.initialCount}
- 불러온 이벤트 : $eventName
- 프린터 연결 상태 : 정상
- 결제 단말기 연결 상태 : ${isPaymentOn == true ? '정상' : '미연결'}
- 프린터 온도 : $printerheadTempString°C
- 리본 잔량 : ${printLog?.rbnRemainingRatio != null ? "${printLog?.rbnRemainingRatio}%" : "알 수 없음"}
- 필름 잔량 : ${printLog?.filmRemainingRatio != null ? "${printLog?.filmRemainingRatio}%" : "알 수 없음"}
''';

      final message = buildSlackAlertMessage(
        slackLogTemplate: slackLogTemplate.copyWith(description: description),
        cardCount: cardCount.currentCount,
      );

      await sendLog(slackWebhookBroadcastUrl, message);
    }
  }

  Future<void> sendPaymentBroadcastLogToSlak(String errorKey, {required String paymentDescription}) async {
    final slackLogTemplate = await createSlackLogTemplate(errorKey);

    if (slackLogTemplate.category.isNotEmpty) {
      String description;

      description = '''
${slackLogTemplate.description}
            
- $paymentDescription''';

      final message = buildSlackAlertMessage(slackLogTemplate: slackLogTemplate.copyWith(description: description));

      await sendLog(slackWebhookBroadcastUrl, message);
    }
  }

  Future<void> sendPeriodicLogBroadcastLogToSlack() async {
    final slackLogTemplate = await createSlackLogTemplate(null);
    final machineId = slackLogTemplate.kioskMachineInfo?.kioskMachineId ?? 0;

    if (machineId != 0) {
      final printerLog = _container.read(printerLogProvider);
      final cardCount = _container.read(cardCountProvider);
      String description;

      description = '''
- 리본 잔량 : ${printerLog?.rbnRemainingRatio != null ? "${printerLog?.rbnRemainingRatio}%" : "알 수 없음"}
- 필름 잔량 : ${printerLog?.filmRemainingRatio != null ? "${printerLog?.filmRemainingRatio}%" : "알 수 없음"}
- 단면 카드 수량 : ${cardCount.currentCount} / ${cardCount.initialCount}
''';

      final message = buildSlackAlertMessage(
          slackLogTemplate: slackLogTemplate.copyWith(title: '프린트 상태', category: 'info', description: description));

      await sendLog(slackWebhookBroadcastUrl, message);
    }
  }

  Future<void> sendBroadcastLogToSlack(String errorKey) async {
    final slackLogTemplate = await createSlackLogTemplate(errorKey);
    final cardCount = _container.read(cardCountProvider);

    if (slackLogTemplate.category.isNotEmpty) {
      final message = buildSlackAlertMessage(
        slackLogTemplate: slackLogTemplate,
        cardCount: cardCount.currentCount,
      );

      await sendLog(slackWebhookBroadcastUrl, message);
    }
  }

  Future<void> sendLog(String? url, String message) async {
    if (url == null) {
      log("❌ Slack Webhook URL이 없습니다.");
      return;
    }
    if (message.isEmpty) {
      log("❌ Slack Webhook 메시지가 없습니다.");
      return;
    } else {
      final payload = jsonEncode({"text": message});

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: payload,
        );

        if (response.statusCode != 200) {
          log("❌ Slack Webhook 오류: ${response.body}");
          log("curl -X POST -H \"Content-Type: application/json\" -d '$payload' $url");
        }
      } catch (e) {
        log("❌ Slack Webhook 오류: $e");
        log("curl -X POST -H \"Content-Type: application/json\" -d '$payload' $url");
      }
    }
  }

  String buildSlackAlertMessage({
    required SlackLogTemplate slackLogTemplate,
    int? cardCount,
  }) {
    final cardInfo = '''
${cardCount == 0 ? "- 단면 -> 양면 모드" : "- 단면 모드 설정\n- 단면 설정 개수 : $cardCount개"}
      ''';

    final emojiMap = {
      'error': '🔴',
      'warning': '🟡',
      'info': '🟢',
    };
    final emoji = emojiMap[slackLogTemplate.category.toLowerCase()] ?? 'ℹ️';

    final formattedTitle = (slackLogTemplate.title == "점검 완료" || slackLogTemplate.title == "점검 시작")
        ? '🟢  *${slackLogTemplate.title}*'
        : '$emoji  *${slackLogTemplate.title}*';

    final guidePart = slackLogTemplate.guideText != null
        ? "[${slackLogTemplate.guideUrl != null ? '<${slackLogTemplate.guideUrl}|${slackLogTemplate.guideText}>' : slackLogTemplate.guideText}]"
        : '';

    return '''
$formattedTitle
───────────────────
Kiosk: ${slackLogTemplate.kioskMachineInfo?.kioskMachineId ?? 0}  /  ${slackLogTemplate.appVersion}
업체(구단): ${slackLogTemplate.serviceName}
───────────────────
${slackLogTemplate.description}
${slackLogTemplate.title == "카드 인쇄 모드 변경" ? cardInfo : ""}
$guidePart
''';
  }
}

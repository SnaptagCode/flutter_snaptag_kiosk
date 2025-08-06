import 'dart:convert';
import 'dart:developer';

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

  Future<void> sendBroadcastLogToSlack(String errorKey) async {
    final definitions = _container.read(alertDefinitionProvider);
    final def = definitions.firstWhereOrNull((e) => e.key == errorKey);
    final kioskInfo = _container.read(kioskInfoServiceProvider);
    final machineId = kioskInfo?.kioskMachineId ?? 0;
    final version =  _container.read(versionStateProvider).currentVersion;
    final cardCount = _container.read(cardCountProvider);
    final eventType = kioskInfo?.eventType ?? "-";
    final eventName = kioskInfo?.printedEventName ?? "-";
    final serviceNameMap = {
      "SUF": "서울 이랜드 FC",
      "SEF": "수원 FC",
      "KEEFO": "성수 B'Day",
    };

    final serviceName = serviceNameMap[eventType] ?? '-';
    String description;
    if (def != null) {
      if (def.key == "Inspection_End"){
          description =
          '''
${def.description}

 - 단면 카드 입력 수량 : $cardCount
 - 불러온 이벤트 : $eventName
 - 프린터 연결 상태 : 정상
'''
          ;
      } else {
        description = def.description;
      }


      final message = buildSlackAlertMessage(
        category: def.category,
        title: def.title,
        serviceName: serviceName,
        kioskId: machineId.toString(),
        appVersion: version,
        description: description,
        guideText: def.guideText,
        guideUrl: def.guideUrl,
        cardCount: cardCount,
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
    required String category,
    required String title,
    required String serviceName,
    required String kioskId,
    required String appVersion,
    required String description,
    String? guideText,
    String? guideUrl,
    int? cardCount,
  }) {
    final cardInfo =
      '''
${cardCount == 0 ? "단면 -> 양면 모드" : "단면 모드 설정"}
        단면 설정 개수 : $cardCount개
      '''
    ;

    final emojiMap = {
      'error': '🔴',
      'warning': '🟡',
      'info': '🟢',
    };
    final emoji = emojiMap[category.toLowerCase()] ?? 'ℹ️';

    final formattedTitle =
    (title == "점검 완료" || title == "점검 시작")
        ? '     *[$title]*'
        : '$emoji  *$title*';

    final guidePart = guideText != null
        ? "[${guideUrl != null ? '<$guideUrl|$guideText>' : guideText}]"
        : '';

    return '''
$formattedTitle
        ────────────────────────────────────────
        KioskID: $kioskId  /  앱버전: $appVersion  /  업체: $serviceName
        ────────────────────────────────────────
        $description
        ${ title == "카드 인쇄 모드 변경" ? cardInfo : ""}
        ────────────────────────────────────────
        $guidePart

''';
  }
}

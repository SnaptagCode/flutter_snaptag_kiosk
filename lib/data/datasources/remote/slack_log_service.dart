import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SlackLogService {
  static final SlackLogService _instance = SlackLogService._internal();
  factory SlackLogService() => _instance;

  final slackWebhookUrl = dotenv.env['SLACK_WEBHOOK_URL'];

  final slackWebhookErrorUrl = dotenv.env['SLACK_WEBHOOK_ERROR_LOG_URL'];

  final slackWebhookRibbonFilmWarnUrl = dotenv.env['SLACK_WEBHOOK_RIBBON_FILM_WARN_URL'];

  final slackWebhookWarningUrl = dotenv.env['SLACK_WEBHOOK_WARNING_URL'];

  SlackLogService._internal() {
    init();
  }

  void init() {
    sendLogToSlack("🚀 Flutter App Started!");
  }

  Future<void> sendErrorLogToSlack({int machineId = 0, required String message}) async {
    await sendLog(slackWebhookErrorUrl, '*[MachineId : $machineId]*\n$message');
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
}

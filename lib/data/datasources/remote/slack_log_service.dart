import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SlackLogService {
  static final SlackLogService _instance = SlackLogService._internal();
  factory SlackLogService() => _instance;

  final slackWebhookUrl = dotenv.env['SLACK_WEBHOOK_URL'];
  SlackLogService._internal() {
    init();
  }

  void init() {
    sendLogToSlack("🚀 Flutter App Started!");
  }

  Future<void> sendLogToSlack(String message) async {
    if (slackWebhookUrl == null) {
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
          Uri.parse(slackWebhookUrl!),
          headers: {"Content-Type": "application/json"},
          body: payload,
        );

        if (response.statusCode != 200) {
          log("❌ Slack Webhook 오류: ${response.body}");
          log("curl -X POST -H \"Content-Type: application/json\" -d '$payload' $slackWebhookUrl");
        }
      } catch (e) {
        log("❌ Slack Webhook 오류: $e");
        log("curl -X POST -H \"Content-Type: application/json\" -d '$payload' $slackWebhookUrl");
      }
    }
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class SlackLogService {
  static final SlackLogService _instance = SlackLogService._internal();
  factory SlackLogService() => _instance;

  SlackLogService._internal() {
    init();
  }

  final String slackWebhookUrl =
      "https://hooks.slack.com/services/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"; // Webhook URL
  void init() {
    sendLogToSlack("🚀 Flutter App Started!");
  }

  Future<void> sendLogToSlack(String message) async {
    final payload = jsonEncode({"text": message});

    try {
      final response = await http.post(
        Uri.parse(slackWebhookUrl),
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

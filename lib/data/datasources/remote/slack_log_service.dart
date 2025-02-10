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
      log(response.body);
      if (response.statusCode != 200) {
        log("❌ Slack Webhook 오류: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      log("❌ Slack Webhook 오류: $e");
    }
  }

  void writeLog(String message) {
    sendLogToSlack(message);
  }
}

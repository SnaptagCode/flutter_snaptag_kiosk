import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// 인터페이스 추상 클래스
abstract class ISlackLogService {
  Future<void> sendRibbonFilmWarningLog(String message);
  Future<void> sendErrorLogToSlack(String message);
  Future<void> sendLogToSlack(String message);
}

// SlackLogService 프로바이더
final slackLogServiceProvider = Provider<ISlackLogService>((ref) {
  return SlackLogService();
});

class SlackLogService implements ISlackLogService {
  static final SlackLogService _instance = SlackLogService._internal();
  factory SlackLogService() => _instance;

  final slackWebhookUrl = dotenv.env['SLACK_WEBHOOK_URL'];

  final slackWebhookErrorUrl = dotenv.env['SLACK_WEBHOOK_ERROR_LOG_URL'];

  final slackWebhookRibbonFilmWarnUrl = dotenv.env['SLACK_WEBHOOK_RIBBON_FILM_WARN_URL'];

  SlackLogService._internal() {
    init();
  }

  void init() {
    sendLogToSlack("🚀 Flutter App Started!");
  }

  @override
  Future<void> sendErrorLogToSlack(String message) async {
    await sendLog(slackWebhookErrorUrl, message);
  }

  @override
  Future<void> sendLogToSlack(String message) async {
    await sendLog(slackWebhookUrl, message);
  }

  @override
  Future<void> sendRibbonFilmWarningLog(String message) async {
    await sendLog(slackWebhookRibbonFilmWarnUrl, message);
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

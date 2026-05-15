import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'slack_log_provider.g.dart';

@Riverpod(keepAlive: true)
ISlackLogService slackLogService(Ref ref) => SlackLogService();

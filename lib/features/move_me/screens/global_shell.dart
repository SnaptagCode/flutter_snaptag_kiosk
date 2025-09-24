import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

class GlobalShell extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GlobalShell> createState() => _GlobalShellState();
}

class _GlobalShellState extends ConsumerState<GlobalShell> {
  @override
  void initState() {
    super.initState();

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      logger.d("================================================\n");
      logger.d("Window Closed");
      SlackLogService().sendErrorLogToSlack("Window Closed");
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AspectRatio(
        aspectRatio: 9 / 16,
        child: widget.child,
      ),
    );
  }
}

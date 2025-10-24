import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';

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
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();

    _periodicTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      SlackLogService().sendLogToSlack("GlobalShell");
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
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

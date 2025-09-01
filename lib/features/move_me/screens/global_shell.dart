import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/providers/kiosk_intro_provider.dart';

class GlobalShell extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalShell({super.key, required this.child});

  @override
  ConsumerState<GlobalShell> createState() => _GlobalShellState();
}

class _GlobalShellState extends ConsumerState<GlobalShell> {
  @override
  void initState() {
    super.initState();
    _initOnce();
  }

  Future<void> _initOnce() async {
    await ref.read(kioskIntroProvider.notifier).load();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalShell extends ConsumerWidget {
  final Widget child;

  const GlobalShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AspectRatio(
        aspectRatio: 9 / 16,
        child: child,
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger_service.dart';

class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<dynamic> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    logger.d('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "newValue": "$newValue"
}''');
  }

  @override
  void didDisposeProvider(ProviderBase<dynamic> provider, ProviderContainer container) {
    logger.d('''
{
  "disposed provider": "${provider.name ?? provider.runtimeType}",
}''');
    super.didDisposeProvider(provider, container);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 전역에서 사용할 현재 폰트 패밀리 상태 Provider
final currentFontFamilyProvider = StateProvider<String>((ref) {
  return 'Cafe24Ssurround2';
});
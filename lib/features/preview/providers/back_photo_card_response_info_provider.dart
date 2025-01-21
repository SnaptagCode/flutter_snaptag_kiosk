import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'back_photo_card_response_info_provider.g.dart';

// 포토카드 정보는 초기값만 필요하므로 일반 Provider 사용
@Riverpod(keepAlive: false)
BackPhotoCardResponse backPhotoCardResponseInfo(Ref ref) {
  throw UnimplementedError('BackPhotoCardResponse must be overridden');
}

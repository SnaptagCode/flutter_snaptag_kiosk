import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/common/log/app_log_service.dart';
import 'package:flutter_snaptag_kiosk/core/common/random/random_photo_util.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'front_photo_list.g.dart';

@Riverpod(keepAlive: true)
class FrontPhotoList extends _$FrontPhotoList {
  @override
  List<NominatedPhoto> build() {
    return [];
  }

  Future<void> loadLocal() async {
    try {
      final dir = Directory(p.join(p.dirname(Platform.resolvedExecutable), 'image', 'front_photos'));
      if (!dir.existsSync()) {
        state = [];
        return;
      }
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) {
            final lower = f.path.toLowerCase();
            return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp');
          })
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      state = files.asMap().entries.map((e) {
        return NominatedPhoto(
          id: e.key,
          embeddingProductId: e.key,
          code: e.key,
          originUrl: '',
          embedUrl: '',
          selectionWeight: 1,
          isWin: true,
          embedImage: e.value,
        );
      }).toList();
      AppLogService.instance.info('앞면 이미지 ${state.length}장 로드 완료');
    } catch (_) {
      state = [];
      AppLogService.instance.error('앞면 이미지 로드 실패');
    }
  }

  int? _lastSelectedId;

  Future<NominatedPhoto> getRandomPhoto() async {
    if (state.isEmpty) {
      throw Exception('No front images available');
    }

    try {
      final candidates = state.length > 1 && _lastSelectedId != null
          ? state.where((photo) => photo.id != _lastSelectedId).toList()
          : state;

      final result = RandomPhotoUtil.getRandomPhotoByWeight(candidates);

      if (result != null) {
        _lastSelectedId = result.id;
        return result;
      }

      throw Exception('Failed to get random photo');
    } catch (e) {
      logger.e('이미지 정보 추출 중 오류가 발생했습니다: $e');
      throw Exception('Failed to get random photo');
    }
  }
}

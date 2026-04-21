import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/common/random/random_photo_util.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'front_photo_list.g.dart';

@Riverpod(keepAlive: true)
class FrontPhotoList extends _$FrontPhotoList {
  @override
  List<NominatedPhoto> build() => [];

  Future<void> fetch() async {
    try {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      final frontPhotosDir = Directory(p.join(exeDir, 'image', 'front_photos'));

      if (!await frontPhotosDir.exists()) {
        state = [];
        return;
      }

      final files = await frontPhotosDir
          .list()
          .where((e) => e is File && _isImageFile(e.path))
          .cast<File>()
          .toList();

      state = files.asMap().entries.map((entry) {
        return NominatedPhoto(
          id: entry.key + 1,
          embeddingProductId: 1,
          code: 1,
          originUrl: '',
          embedUrl: '',
          selectionWeight: 1,
          isWin: false,
          embedImage: entry.value,
        );
      }).toList();
    } catch (e) {
      state = [];
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

  void clearDirectory() {
    state = [];
    _lastSelectedId = null;
  }

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/painting.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_image_cache.g.dart';

enum EventImageKind {
  banner('banner'),
  background('background'),
  emblem('emblem');

  const EventImageKind(this.fileStem);

  final String fileStem;
}

class EventImages {
  const EventImages({this.banner, this.background, this.emblem});

  final File? banner;
  final File? background;
  final File? emblem;

  File? of(EventImageKind kind) => switch (kind) {
        EventImageKind.banner => banner,
        EventImageKind.background => background,
        EventImageKind.emblem => emblem,
      };

  EventImages copyWithKind(EventImageKind kind, File? file) => EventImages(
        banner: kind == EventImageKind.banner ? file : banner,
        background: kind == EventImageKind.background ? file : background,
        emblem: kind == EventImageKind.emblem ? file : emblem,
      );
}

/// 이벤트 이미지(배너·배경·엠블럼)를 `settings/setting_images/`에 파일로 보관한다.
///
/// 화면은 네트워크가 아니라 이 파일을 읽으므로, DNS 블립이나 인터넷 단절 중에도
/// 마지막으로 성공한 이미지가 계속 표시된다.
///
/// 갱신은 **성공했을 때만 교체**한다. 앞면 이미지처럼 먼저 지우고 받으면
/// 갱신 도중 네트워크가 끊겼을 때 있던 이미지마저 사라진다.
@Riverpod(keepAlive: true)
class EventImageCache extends _$EventImageCache {
  final _fileSystem = FileSystemService.instance;

  @override
  EventImages build() => _readFromDisk();

  Future<void> fetch() async {
    final info = ref.read(kioskInfoServiceProvider);
    if (info == null) return;

    await _fileSystem.ensureDirectoryExists(DirectoryPaths.settingImages);

    await Future.wait([
      _refresh(EventImageKind.banner, info.topBannerUrl),
      _refresh(EventImageKind.background, info.mainImageUrl),
      _refresh(EventImageKind.emblem, info.emblemImageUrl),
    ]);
  }

  Future<void> _refresh(EventImageKind kind, String url) async {
    if (url.isEmpty) return;

    try {
      final dio.Response response = await ImageHelper().getImageBytes(url);
      final contentType = response.headers.value('content-type');
      final extension = contentType != null
          ? ImageHelper().getFileExtensionFromContentType(contentType)
          : ImageHelper().getFileExtensionFromUrl(url);

      final bytes = Uint8List.fromList(response.data as List<int>);
      final saved = await _replace(kind, bytes, extension);

      state = state.copyWithKind(kind, saved);
    } catch (e) {
      logger.i('EventImageCache: ${kind.name} 갱신 실패, 기존 파일 유지 - $e');
    }
  }

  /// 임시 파일로 받은 뒤 교체한다. 쓰기 도중 중단돼도 기존 파일이 깨지지 않는다.
  ///
  /// [FileImage]는 경로를 캐시 키로 쓰므로, 같은 경로에 새 이미지를 덮으면
  /// 화면이 예전 이미지를 계속 그린다. 교체 후 반드시 캐시에서 비워야 한다.
  Future<File> _replace(EventImageKind kind, Uint8List bytes, String extension) async {
    final dirPath = DirectoryPaths.settingImages.buildPath;
    final temp = File('$dirPath/${kind.fileStem}.tmp');
    await temp.writeAsBytes(bytes);

    for (final stale in _filesFor(kind)) {
      await FileImage(stale).evict();
      await stale.delete();
    }

    final target = File('$dirPath/${kind.fileStem}$extension');
    final saved = await temp.rename(target.path);
    await FileImage(saved).evict();
    return saved;
  }

  EventImages _readFromDisk() {
    var images = const EventImages();
    for (final kind in EventImageKind.values) {
      final existing = _filesFor(kind);
      if (existing.isNotEmpty) {
        images = images.copyWithKind(kind, existing.first);
      }
    }
    return images;
  }

  List<File> _filesFor(EventImageKind kind) {
    final dir = Directory(DirectoryPaths.settingImages.buildPath);
    if (!dir.existsSync()) return const [];

    return dir
        .listSync()
        .whereType<File>()
        .where((file) => _stemOf(file) == kind.fileStem && !file.path.endsWith('.tmp'))
        .toList();
  }

  String _stemOf(File file) {
    final name = file.uri.pathSegments.last;
    final lastDot = name.lastIndexOf('.');
    return lastDot == -1 ? name : name.substring(0, lastDot);
  }
}

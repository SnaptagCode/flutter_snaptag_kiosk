import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/data/models/entities/version_state.dart';
import 'package:flutter_snaptag_kiosk/core/data/repositories/version_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'version_notifier.g.dart';

@riverpod
VersionRepository versionRepository(Ref ref) => VersionRepository();

@Riverpod(keepAlive: true)
class VersionNotifier extends _$VersionNotifier {
  @override
  VersionState build() {
    loadVersions();
    return VersionState(currentVersion: 'v2.4.9', latestVersion: 'v2.4.9', isLoading: true);
  }

  Future<void> loadVersions() async {
    try {
      final repo = ref.read(versionRepositoryProvider);
      final current = await repo.getCurrentVersion();
      final latest = await repo.getLatestVersionFromGitHub();
      state = state.copyWith(currentVersion: current, latestVersion: latest, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/data/repositories/version_repository.dart';
import 'package:flutter_snaptag_kiosk/data/models/entities/version_state.dart';

final versionRepositoryProvider = Provider((ref) => VersionRepository());

final versionStateProvider = StateNotifierProvider<VersionNotifier, VersionState>(
      (ref) => VersionNotifier(ref.read(versionRepositoryProvider)),
);

class VersionNotifier extends StateNotifier<VersionState> {
  final VersionRepository _repo;

  VersionNotifier(this._repo)
      : super(VersionState(currentVersion: 'v2.4.6h', latestVersion: 'v2.4.6h', isLoading: true)) {
    loadVersions();
  }

  Future<void> loadVersions() async {
    try {
      final current = await _repo.getCurrentVersion();
      final latest = await _repo.getLatestVersionFromGitHub();
      state = state.copyWith(
        currentVersion: current,
        latestVersion: latest,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

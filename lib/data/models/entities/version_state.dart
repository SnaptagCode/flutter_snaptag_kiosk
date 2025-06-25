class VersionState {
  final String currentVersion;
  final String latestVersion;
  final bool isLoading;
  final String? error;

  VersionState({
    this.currentVersion = "v2.4.9",
    this.latestVersion = "v2.4.9",
    this.isLoading = false,
    this.error,
  });

  VersionState copyWith({
    String? currentVersion,
    String? latestVersion,
    bool? isLoading,
    String? error,
  }) {
    return VersionState(
      currentVersion: currentVersion ?? this.currentVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VersionState {
  final String currentVersion;
  final String latestVersion;
  final bool isLoading;
  final String? error;

  VersionState({
    required this.currentVersion,
    required this.latestVersion,
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

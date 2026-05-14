import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_preview_state.freezed.dart';

@freezed
sealed class EventPreviewState with _$EventPreviewState {
  const factory EventPreviewState.initial() = EventPreviewStateInitial;
  const factory EventPreviewState.loading() = EventPreviewStateLoading;
  const factory EventPreviewState.refreshSuccess() = EventPreviewStateRefreshSuccess;
  const factory EventPreviewState.failure(Object error) = EventPreviewStateFailure;
}

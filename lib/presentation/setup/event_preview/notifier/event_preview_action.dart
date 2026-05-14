import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_preview_action.freezed.dart';

@freezed
sealed class EventPreviewAction with _$EventPreviewAction {
  const factory EventPreviewAction.requestRefresh() = EventPreviewActionRequestRefresh;
  const factory EventPreviewAction.confirmRefresh(int machineId) = EventPreviewActionConfirmRefresh;
}

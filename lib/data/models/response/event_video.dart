import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_video.freezed.dart';
part 'event_video.g.dart';

@freezed
class EventVideo with _$EventVideo {
  const factory EventVideo({
    @Default(0) int id,
    @Default('') String videoUrl,
    @Default('') String created,
  }) = _EventVideo;

  factory EventVideo.fromJson(Map<String, dynamic> json) => _$EventVideoFromJson(json);
}

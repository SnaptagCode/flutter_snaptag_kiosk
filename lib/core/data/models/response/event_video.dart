import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_video.freezed.dart';
part 'event_video.g.dart';

@freezed
class EventVideo with _$EventVideo {
  const factory EventVideo({
    required int id,
    required String videoUrl,
    required String created,
  }) = _EventVideo;

  factory EventVideo.fromJson(Map<String, dynamic> json) => _$EventVideoFromJson(json);
}

import 'package:musee/features/search/domain/entities/video_info.dart';

class VideoInfoModel extends VideoInfo {
  VideoInfoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.uploader,
    required super.thumbnailUrl,
    required super.videoUrl,
    required super.duration,
  });

  factory VideoInfoModel.fromJson(Map<String, dynamic> json) {
    return VideoInfoModel(
      id: json['video_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      uploader: json['uploader'] ?? '',
      thumbnailUrl: json['thumbnail'] ?? '',
      videoUrl: json['video_url'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }
}

class VideoInfo {
  final String id;
  final String title;
  final String description;
  final String uploader;
  final String thumbnailUrl;
  final String videoUrl;
  final int duration;
  final bool containsCachedQuality;

  VideoInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.uploader,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    this.containsCachedQuality = false,
  });
}

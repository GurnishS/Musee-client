class SearchResult {
  final String title;
  final String type;
  final String extractorKey;
  final List<SearchItem> results;

  SearchResult({
    required this.title,
    required this.type,
    required this.extractorKey,
    required this.results,
  });
}

class SearchItem {
  final String id;
  final String title;
  final String url;
  final String? description;
  final String? thumbnail;
  final int? duration;
  final String? uploader;
  final String? uploadDate;

  SearchItem({
    required this.id,
    required this.title,
    required this.url,
    this.description,
    this.thumbnail,
    this.duration,
    this.uploader,
    this.uploadDate,
  });
}
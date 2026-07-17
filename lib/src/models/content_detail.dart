/// Chapitre de manga ou épisode d'anime.
class Chapter {
  final String url;
  final String? name;
  final String? dateUpload;
  final double? chapterNumber;
  final String? scanlator;

  const Chapter({
    required this.url,
    this.name,
    this.dateUpload,
    this.chapterNumber,
    this.scanlator,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        url: (json['url'] ?? '') as String,
        name: json['name'] as String?,
        dateUpload: json['dateUpload']?.toString(),
        chapterNumber: (json['chapterNumber'] as num?)?.toDouble(),
        scanlator: json['scanlator'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        if (name != null) 'name': name,
        if (dateUpload != null) 'dateUpload': dateUpload,
        if (chapterNumber != null) 'chapterNumber': chapterNumber,
        if (scanlator != null) 'scanlator': scanlator,
      };

  @override
  String toString() => 'Chapter(name: $name, url: $url)';
}

/// Détail complet d'un contenu (manga ou anime) avec ses chapitres/épisodes.
class ContentDetail {
  final String? name;
  final String? description;
  final String? imageUrl;
  final String? author;
  final String? status;
  final List<String> genres;

  /// Chapitres (manga/novel).
  final List<Chapter> chapters;

  /// Épisodes (anime/vidéo) — même structure que chapters.
  final List<Chapter> episodes;

  const ContentDetail({
    this.name,
    this.description,
    this.imageUrl,
    this.author,
    this.status,
    this.genres = const [],
    this.chapters = const [],
    this.episodes = const [],
  });

  factory ContentDetail.fromJson(Map<String, dynamic> json) {
    List<Chapter> parseChapters(dynamic raw) =>
        (raw as List<dynamic>? ?? [])
            .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList();

    return ContentDetail(
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: (json['imageUrl'] ?? json['thumbnailUrl']) as String?,
      author: json['author'] as String?,
      status: json['status'] as String?,
      genres: (json['genre'] as List<dynamic>?)?.cast<String>() ?? [],
      chapters: parseChapters(json['chapters']),
      episodes: parseChapters(json['episodes']),
    );
  }

  /// Retourne episodes si présents, sinon chapters (utile pour les sources mixtes).
  List<Chapter> get allEpisodes => episodes.isNotEmpty ? episodes : chapters;

  @override
  String toString() =>
      'ContentDetail(name: $name, chapters: ${chapters.length}, episodes: ${episodes.length})';
}

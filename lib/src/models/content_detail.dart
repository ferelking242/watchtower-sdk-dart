/// Chapitre (manga/novel) ou épisode (anime).
class Chapter {
  /// URL du chapitre ou de l'épisode (utilisée pour pages/videos).
  final String url;

  /// Titre ou numéro.
  final String name;

  /// Date de mise en ligne (timestamp ms ou string ISO).
  final String? dateUpload;

  /// Numéro de chapitre/épisode.
  final double? chapterNumber;

  /// Groupe de scanlation ou sous-titrage.
  final String? scanlator;

  const Chapter({
    required this.url,
    required this.name,
    this.dateUpload,
    this.chapterNumber,
    this.scanlator,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        url: (json['url'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        dateUpload: json['dateUpload']?.toString(),
        chapterNumber: (json['chapterNumber'] as num?)?.toDouble(),
        scanlator: json['scanlator'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'name': name,
        if (dateUpload != null) 'dateUpload': dateUpload,
        if (chapterNumber != null) 'chapterNumber': chapterNumber,
        if (scanlator != null) 'scanlator': scanlator,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Chapter && other.url == url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'Chapter(name: $name, url: $url)';
}

/// Détail complet d'un contenu — manga, anime, novel ou musique.
class ContentDetail {
  /// Titre du contenu.
  final String name;

  /// Description.
  final String? description;

  /// URL de la couverture.
  final String? imageUrl;

  /// Auteur ou studio.
  final String? author;

  /// Statut (ex: `Completed`, `Ongoing`).
  final String? status;

  /// Liste des genres.
  final List<String> genre;

  /// Chapitres (manga/novel). Vide pour les sources vidéo.
  final List<Chapter> chapters;

  /// Épisodes (anime/vidéo). Vide pour les sources manga.
  final List<Chapter> episodes;

  const ContentDetail({
    required this.name,
    this.description,
    this.imageUrl,
    this.author,
    this.status,
    this.genre = const [],
    this.chapters = const [],
    this.episodes = const [],
  });

  /// `true` si le contenu est de type vidéo/anime (a des épisodes).
  bool get isVideo => episodes.isNotEmpty;

  /// `true` si le contenu est de type manga/novel (a des chapitres).
  bool get isManga => chapters.isNotEmpty;

  /// Tous les "chapitres" — fusionné pour un accès générique.
  List<Chapter> get allChapters => isVideo ? episodes : chapters;

  factory ContentDetail.fromJson(Map<String, dynamic> json) => ContentDetail(
        name: (json['name'] ?? '') as String,
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        author: json['author'] as String?,
        status: json['status'] as String?,
        genre: (json['genre'] as List<dynamic>?)?.cast<String>() ?? const [],
        chapters: ((json['chapters'] as List<dynamic>?) ?? [])
            .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList(),
        episodes: ((json['episodes'] as List<dynamic>?) ?? [])
            .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (author != null) 'author': author,
        if (status != null) 'status': status,
        if (genre.isNotEmpty) 'genre': genre,
        if (chapters.isNotEmpty) 'chapters': chapters.map((e) => e.toJson()).toList(),
        if (episodes.isNotEmpty) 'episodes': episodes.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() =>
      'ContentDetail(name: $name, chapters: ${chapters.length}, episodes: ${episodes.length})';
}

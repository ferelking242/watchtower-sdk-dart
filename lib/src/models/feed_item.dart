import 'coerce.dart';

/// Élément retourné dans les listes popular / latest / search.
class FeedItem {
  /// URL de la page de détail (utilisée pour [SourcesEndpoint.detail]).
  final String link;

  /// Titre du contenu.
  final String name;

  /// URL de la miniature.
  final String? imageUrl;

  /// Auteur ou studio.
  final String? author;

  /// Description courte.
  final String? description;

  /// Liste des genres.
  final List<String> genre;

  /// Statut (ex: `Completed`, `Ongoing`).
  final String? status;

  const FeedItem({
    required this.link,
    required this.name,
    this.imageUrl,
    this.author,
    this.description,
    this.genre = const [],
    this.status,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
        link: coerceString(json['link'] ?? json['url']),
        name: coerceString(json['name'] ?? json['title']),
        imageUrl: coerceStringOrNull(json['imageUrl']),
        author: coerceStringOrNull(json['author']),
        description: coerceStringOrNull(json['description']),
        genre: coerceStringList(json['genre']),
        status: coerceStringOrNull(json['status']),
      );

  Map<String, dynamic> toJson() => {
        'link': link,
        'name': name,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (author != null) 'author': author,
        if (description != null) 'description': description,
        if (genre.isNotEmpty) 'genre': genre,
        if (status != null) 'status': status,
      };

  FeedItem copyWith({
    String? link,
    String? name,
    String? imageUrl,
    String? author,
    String? description,
    List<String>? genre,
    String? status,
  }) =>
      FeedItem(
        link: link ?? this.link,
        name: name ?? this.name,
        imageUrl: imageUrl ?? this.imageUrl,
        author: author ?? this.author,
        description: description ?? this.description,
        genre: genre ?? this.genre,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FeedItem && other.link == link;

  @override
  int get hashCode => link.hashCode;

  @override
  String toString() => 'FeedItem(name: $name, link: $link)';
}

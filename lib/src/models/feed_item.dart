/// Élément retourné dans les listes popular / latest / search.
class FeedItem {
  /// URL de la page de détail sur la source distante.
  final String link;

  /// Titre du contenu.
  final String name;

  /// URL de la miniature.
  final String? imageUrl;

  final String? author;
  final String? description;
  final List<String> genres;
  final String? status;

  const FeedItem({
    required this.link,
    required this.name,
    this.imageUrl,
    this.author,
    this.description,
    this.genres = const [],
    this.status,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
        link: (json['link'] ?? json['url'] ?? '') as String,
        name: (json['name'] ?? json['title'] ?? '') as String,
        imageUrl: (json['imageUrl'] ?? json['thumbnailUrl']) as String?,
        author: json['author'] as String?,
        description: json['description'] as String?,
        genres: (json['genre'] as List<dynamic>?)?.cast<String>() ?? [],
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'link': link,
        'name': name,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (author != null) 'author': author,
        if (description != null) 'description': description,
        if (genres.isNotEmpty) 'genre': genres,
        if (status != null) 'status': status,
      };

  @override
  String toString() => 'FeedItem(name: $name, link: $link)';
}

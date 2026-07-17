/// Page d'un chapitre manga retournée par `/pages`.
class MangaPage {
  /// Index de la page (commence à 0).
  final int page;

  /// URL de l'image.
  final String url;

  /// Headers HTTP supplémentaires requis pour charger l'image.
  final Map<String, String> headers;

  const MangaPage({
    required this.page,
    required this.url,
    this.headers = const {},
  });

  factory MangaPage.fromJson(Map<String, dynamic> json) => MangaPage(
        page: (json['page'] as num?)?.toInt() ?? 0,
        url: (json['url'] ?? json['imageUrl'] ?? '') as String,
        headers: Map<String, String>.from(
          (json['headers'] as Map<String, dynamic>? ?? {}).map(
            (k, v) => MapEntry(k, v.toString()),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'url': url,
        if (headers.isNotEmpty) 'headers': headers,
      };

  @override
  String toString() => 'MangaPage(page: $page, url: $url)';
}

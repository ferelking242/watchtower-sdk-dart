import '../http_client.dart';
import '../pagination.dart';
import '../models/source.dart';
import '../models/items_page.dart';
import '../models/content_detail.dart';
import '../models/video_stream.dart';
import '../models/manga_page.dart';
import '../models/filter.dart';

/// Toutes les opérations sur les sources et leur contenu.
///
/// Accédé via [WatchtowerClient.sources].
class SourcesEndpoint {
  final WatchtowerHttpClient _http;

  const SourcesEndpoint(this._http);

  // ── Catalogue ──────────────────────────────────────────────────────────────

  /// Liste toutes les sources disponibles (sources NSFW exclues).
  ///
  /// Throws [WatchtowerApiException] si la clé API est invalide (401).
  Future<List<Source>> list() async {
    final data = await _http.get('/api/sources');
    final raw = data['sources'] as List<dynamic>? ?? [];
    return raw.map((e) => Source.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Récupère une source par son identifiant.
  ///
  /// Throws [WatchtowerApiException] 404 si la source n'existe pas,
  /// 403 si la source est NSFW.
  Future<Source> get(String id) async {
    final data = await _http.get('/api/sources/$id');
    return Source.fromJson(data);
  }

  // ── Contenu ────────────────────────────────────────────────────────────────

  /// Contenus populaires d'une source, paginés.
  ///
  /// [page] commence à 1.
  Future<ItemsPage> popular(String id, {int page = 1}) async {
    final data = await _http.get(
      '/api/sources/$id/popular',
      queryParams: {'page': page.toString()},
    );
    return ItemsPage.fromJson(data);
  }

  /// Dernières mises à jour d'une source, paginées.
  ///
  /// [page] commence à 1.
  Future<ItemsPage> latest(String id, {int page = 1}) async {
    final data = await _http.get(
      '/api/sources/$id/latest',
      queryParams: {'page': page.toString()},
    );
    return ItemsPage.fromJson(data);
  }

  /// Recherche dans une source.
  ///
  /// Passer une chaîne vide pour lister sans filtre.
  Future<ItemsPage> search(String id, String query, {int page = 1}) async {
    final data = await _http.get(
      '/api/sources/$id/search',
      queryParams: {'q': query, 'page': page.toString()},
    );
    return ItemsPage.fromJson(data);
  }

  /// Détail complet d'un contenu : titre, couverture, chapitres/épisodes.
  ///
  /// [url] est la valeur [FeedItem.link] obtenue depuis popular/latest/search.
  Future<ContentDetail> detail(String id, {required String url}) async {
    final data = await _http.get(
      '/api/sources/$id/detail',
      queryParams: {'url': url},
    );
    return ContentDetail.fromJson(data);
  }

  /// Streams vidéo d'un épisode (qualités disponibles).
  ///
  /// [url] est la valeur [Chapter.url] obtenue depuis [detail].
  Future<List<VideoStream>> videos(String id, {required String url}) async {
    final data = await _http.get(
      '/api/sources/$id/videos',
      queryParams: {'url': url},
    );
    final raw = data['videos'] as List<dynamic>? ?? [];
    return raw
        .map((e) => VideoStream.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Pages d'un chapitre manga.
  ///
  /// [url] est la valeur [Chapter.url] obtenue depuis [detail].
  Future<List<MangaPage>> pages(String id, {required String url}) async {
    final data = await _http.get(
      '/api/sources/$id/pages',
      queryParams: {'url': url},
    );
    final raw = data['pages'] as List<dynamic>? ?? [];
    return raw
        .map((e) => MangaPage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Filtres de recherche avancée disponibles pour une source.
  Future<List<Filter>> filters(String id) async {
    final data = await _http.get('/api/sources/$id/filters');
    final raw = data['filters'] as List<dynamic>? ?? [];
    return raw
        .map((e) => Filter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Pagination helpers ─────────────────────────────────────────────────────

  /// Helpers de pagination automatique.
  ///
  /// ```dart
  /// // Stream de tous les items populaires
  /// await for (final item in client.sources.paginate.popular('crunchyroll').items()) {
  ///   print(item.name);
  /// }
  ///
  /// // Collecter les 3 premières pages de recherche
  /// final results = await client.sources.paginate
  ///     .search('crunchyroll', 'demon slayer')
  ///     .collect(maxPages: 3);
  /// ```
  PaginateEndpoint get paginate => PaginateEndpoint(
        popular: (id, {int startPage = 1}) =>
            (int p) => popular(id, page: p),
        latest: (id, {int startPage = 1}) =>
            (int p) => latest(id, page: p),
        search: (id, query) => (int p) => search(id, query, page: p),
      );
}

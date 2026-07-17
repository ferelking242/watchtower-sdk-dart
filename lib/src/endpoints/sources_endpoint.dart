import '../http_client.dart';
import '../models/source.dart';
import '../models/items_page.dart';
import '../models/content_detail.dart';
import '../models/video_stream.dart';
import '../models/manga_page.dart';
import '../models/filter.dart';

/// Toutes les opérations sur les sources et leur contenu.
class SourcesEndpoint {
  final WatchtowerHttpClient _http;
  const SourcesEndpoint(this._http);

  // ── Catalogue ──────────────────────────────────────────────────────────────

  /// Liste toutes les sources disponibles (non-NSFW).
  Future<List<Source>> list() async {
    final data = await _http.get('/api/sources');
    final raw = (data['sources'] as List<dynamic>? ?? []);
    return raw.map((e) => Source.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Récupère une source par son identifiant.
  Future<Source> get(String id) async {
    final data = await _http.get('/api/sources/$id');
    return Source.fromJson(data);
  }

  // ── Contenu ────────────────────────────────────────────────────────────────

  /// Contenus populaires d'une source, paginés.
  Future<ItemsPage> popular(String id, {int page = 1}) async {
    final data = await _http.get(
      '/api/sources/$id/popular',
      queryParams: {'page': page.toString()},
    );
    return ItemsPage.fromJson(data);
  }

  /// Dernières mises à jour d'une source, paginées.
  Future<ItemsPage> latest(String id, {int page = 1}) async {
    final data = await _http.get(
      '/api/sources/$id/latest',
      queryParams: {'page': page.toString()},
    );
    return ItemsPage.fromJson(data);
  }

  /// Recherche dans une source.
  Future<ItemsPage> search(String id, String query, {int page = 1}) async {
    final data = await _http.get(
      '/api/sources/$id/search',
      queryParams: {'q': query, 'page': page.toString()},
    );
    return ItemsPage.fromJson(data);
  }

  /// Détail d'un contenu (chapitres ou épisodes).
  Future<ContentDetail> detail(String id, {required String url}) async {
    final data = await _http.get(
      '/api/sources/$id/detail',
      queryParams: {'url': url},
    );
    return ContentDetail.fromJson(data);
  }

  /// Streams vidéo d'un épisode.
  Future<List<VideoStream>> videos(String id, {required String url}) async {
    final data = await _http.get(
      '/api/sources/$id/videos',
      queryParams: {'url': url},
    );
    final raw = data['videos'] as List<dynamic>? ?? [];
    return raw.map((e) => VideoStream.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Pages d'un chapitre manga.
  Future<List<MangaPage>> pages(String id, {required String url}) async {
    final data = await _http.get(
      '/api/sources/$id/pages',
      queryParams: {'url': url},
    );
    final raw = data['pages'] as List<dynamic>? ?? [];
    return raw.map((e) => MangaPage.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Filtres de recherche avancée d'une source.
  Future<List<Filter>> filters(String id) async {
    final data = await _http.get('/api/sources/$id/filters');
    final raw = data['filters'] as List<dynamic>? ?? [];
    return raw.map((e) => Filter.fromJson(e as Map<String, dynamic>)).toList();
  }
}

import 'models/items_page.dart';
import 'models/feed_item.dart';

/// Signature d'une fonction qui fetch une page de résultats.
typedef PageFetcher = Future<ItemsPage> Function(int page);

/// Helper de pagination automatique sur les endpoints Watchtower.
///
/// Obtenu via [SourcesEndpoint.paginator] — ne pas instancier directement.
///
/// ```dart
/// // Itérer sur tous les items (toutes pages confondues)
/// final p = client.sources.paginator.popular('crunchyroll');
/// await for (final item in p.items()) {
///   print('${item.name} — ${item.link}');
/// }
///
/// // Collecter jusqu'à 5 pages en une liste
/// final all = await p.collect(maxPages: 5);
///
/// // Itérer page par page
/// await for (final page in p.pages()) {
///   print('Page avec ${page.length} résultats');
/// }
/// ```
class WatchtowerPaginator {
  final PageFetcher _fetch;

  const WatchtowerPaginator(this._fetch);

  /// Stream de pages de résultats.
  ///
  /// S'arrête automatiquement quand [ItemsPage.hasNextPage] est `false`
  /// ou que la page est vide.
  Stream<ItemsPage> pages() async* {
    int page = 1;
    while (true) {
      final result = await _fetch(page);
      yield result;
      if (!result.hasNextPage || result.isEmpty) break;
      page++;
    }
  }

  /// Stream plat de tous les [FeedItem] sur toutes les pages.
  Stream<FeedItem> items() async* {
    await for (final page in pages()) {
      for (final item in page.items) {
        yield item;
      }
    }
  }

  /// Collecte tous les items jusqu'à [maxPages] pages incluses.
  ///
  /// [maxPages] évite les boucles infinies sur les sources mal configurées.
  /// Défaut : 20 pages.
  Future<List<FeedItem>> collect({int maxPages = 20}) async {
    final results = <FeedItem>[];
    int page = 1;
    while (page <= maxPages) {
      final result = await _fetch(page);
      results.addAll(result.items);
      if (!result.hasNextPage || result.isEmpty) break;
      page++;
    }
    return results;
  }

  /// Retourne uniquement la première page.
  Future<ItemsPage> first() => _fetch(1);
}

/// Namespace de paginateurs exposé par [SourcesEndpoint].
class PaginateEndpoint {
  final PageFetcher Function(String id, {int startPage}) _popularFn;
  final PageFetcher Function(String id, {int startPage}) _latestFn;
  final PageFetcher Function(String id, String query) _searchFn;

  const PaginateEndpoint({
    required PageFetcher Function(String id, {int startPage}) popular,
    required PageFetcher Function(String id, {int startPage}) latest,
    required PageFetcher Function(String id, String query) search,
  })  : _popularFn = popular,
        _latestFn = latest,
        _searchFn = search;

  /// Paginator sur les contenus populaires d'une source.
  WatchtowerPaginator popular(String id) =>
      WatchtowerPaginator((p) => _popularFn(id)(p));

  /// Paginator sur les dernières mises à jour d'une source.
  WatchtowerPaginator latest(String id) =>
      WatchtowerPaginator((p) => _latestFn(id)(p));

  /// Paginator sur les résultats de recherche d'une source.
  WatchtowerPaginator search(String id, String query) =>
      WatchtowerPaginator((p) => _searchFn(id, query)(p));
}

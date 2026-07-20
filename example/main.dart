// ignore_for_file: avoid_print
import 'package:watchtower_client/watchtower_client.dart';

/// Exemple complet d'utilisation du SDK Watchtower.
void main() async {
  final client = WatchtowerClient(
    url: 'https://mon-serveur.railway.app',
    apiKey: 'mysecretkey', // optionnel si serveur sans API_KEY
    timeout: const Duration(seconds: 20),
    maxRetries: 3,
  );

  try {
    // ── Health check ──────────────────────────────────────────────────────
    final ok = await client.ping();
    print('Serveur OK: $ok');

    // ── Catalogue de sources ──────────────────────────────────────────────
    final sources = await client.sources.list();
    print('\n${sources.length} sources disponibles :');
    for (final s in sources.take(5)) {
      print('  • ${s.name} (${s.lang}) — ${s.itemType.name}');
    }

    if (sources.isEmpty) return;
    final sourceId = sources.first.id;

    // ── Page de contenu populaire ─────────────────────────────────────────
    final page = await client.sources.popular(sourceId, page: 1);
    print('\nPopulaire (${page.length} items, hasNext: ${page.hasNextPage})');
    for (final item in page.items.take(3)) {
      print('  • ${item.name}');
    }

    // ── Pagination automatique ────────────────────────────────────────────
    print('\nPagination auto (max 3 pages) :');
    final allItems = await client.sources.paginate
        .popular(sourceId)
        .collect(maxPages: 3);
    print('  → ${allItems.length} items collectés');

    // ── Recherche ─────────────────────────────────────────────────────────
    final results = await client.sources.search(sourceId, 'one piece');
    print('\nRecherche "one piece" : ${results.length} résultats');

    if (page.items.isEmpty) return;
    final firstItem = page.items.first;

    // ── Détail ────────────────────────────────────────────────────────────
    final detail = await client.sources.detail(sourceId, url: firstItem.link);
    print('\nDétail : ${detail.name}');
    print('  Chapitres : ${detail.chapters.length}');
    print('  Épisodes  : ${detail.episodes.length}');

    final chapters = detail.allChapters;
    if (chapters.isEmpty) return;

    // ── Streams vidéo ─────────────────────────────────────────────────────
    if (detail.isVideo) {
      final streams = await client.sources.videos(sourceId, url: chapters.first.url);
      print('\nStreams vidéo (${streams.length}) :');
      for (final v in streams) {
        print('  • ${v.quality} — ${v.isM3U8 ? 'HLS' : v.isMPD ? 'DASH' : 'MP4'}');
      }
    }

    // ── Pages manga ───────────────────────────────────────────────────────
    if (detail.isManga) {
      final pages = await client.sources.pages(sourceId, url: chapters.last.url);
      print('\nPages manga : ${pages.length} images');
    }

    // ── Filtres de recherche ──────────────────────────────────────────────
    final filters = await client.sources.filters(sourceId);
    print('\nFiltres disponibles : ${filters.length}');
    for (final f in filters.take(3)) {
      print('  • ${f.name} (${f.type}) — ${f.options.length} options');
    }
  } on WatchtowerApiException catch (e) {
    print('Erreur API ${e.statusCode}: ${e.message}');
  } on WatchtowerNetworkException catch (e) {
    print('Erreur réseau: ${e.message}');
  } finally {
    client.close();
  }
}

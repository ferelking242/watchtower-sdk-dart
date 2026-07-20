/// Client Dart/Flutter officiel pour l'API REST Watchtower.
///
/// ## Installation
///
/// ```yaml
/// # pubspec.yaml
/// dependencies:
///   watchtower_client:
///     git:
///       url: https://github.com/ferelking242/watchtower-sdk-dart.git
///       ref: main
/// ```
///
/// ## Usage rapide
///
/// ```dart
/// import 'package:watchtower_client/watchtower_client.dart';
///
/// void main() async {
///   final client = WatchtowerClient(
///     url: 'https://mon-serveur.railway.app',
///     apiKey: 'mysecretkey',
///   );
///
///   // Health check
///   final ok = await client.ping();
///
///   // Lister les sources
///   final sources = await client.sources.list();
///
///   // Contenus populaires (une page)
///   final page = await client.sources.popular('crunchyroll', page: 1);
///
///   // Pagination automatique — tous les items
///   await for (final item in client.sources.paginate.popular('crunchyroll').items()) {
///     print(item.name);
///   }
///
///   // Streams vidéo d'un épisode
///   final streams = await client.sources.videos('crunchyroll', url: page.items.first.link);
///
///   client.close();
/// }
/// ```
library watchtower_client;

export 'src/client.dart' show WatchtowerClient;
export 'src/http_client.dart' show WatchtowerHttpClient;
export 'src/exceptions.dart'
    show WatchtowerException, WatchtowerNetworkException, WatchtowerApiException;
export 'src/pagination.dart' show WatchtowerPaginator, PaginateEndpoint;
export 'src/endpoints/sources_endpoint.dart' show SourcesEndpoint;
export 'src/models/source.dart' show Source, ItemType;
export 'src/models/feed_item.dart' show FeedItem;
export 'src/models/items_page.dart' show ItemsPage;
export 'src/models/content_detail.dart' show ContentDetail, Chapter;
export 'src/models/video_stream.dart' show VideoStream;
export 'src/models/manga_page.dart' show MangaPage;
export 'src/models/filter.dart' show Filter;

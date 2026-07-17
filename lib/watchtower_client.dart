/// Client Dart officiel pour l'API REST Watchtower.
///
/// Usage :
/// ```dart
/// final client = WatchtowerClient(
///   url: 'https://mon-serveur.railway.app',
///   apiKey: 'mysecretkey',
/// );
///
/// final ok      = await client.ping();
/// final sources = await client.sources.list();
/// final page    = await client.sources.popular('local', page: 1);
/// final streams = await client.sources.videos('local', url: 'https://…');
/// client.close();
/// ```
library watchtower_client;

export 'src/client.dart' show WatchtowerClient;
export 'src/exceptions.dart'
    show WatchtowerException, WatchtowerNetworkException, WatchtowerApiException;
export 'src/models/source.dart' show Source, ItemType;
export 'src/models/feed_item.dart' show FeedItem;
export 'src/models/items_page.dart' show ItemsPage;
export 'src/models/content_detail.dart' show ContentDetail, Chapter;
export 'src/models/video_stream.dart' show VideoStream;
export 'src/models/manga_page.dart' show MangaPage;
export 'src/models/filter.dart' show Filter;

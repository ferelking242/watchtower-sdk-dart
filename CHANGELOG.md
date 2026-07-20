# Changelog

All notable changes to `watchtower_client` are documented here.

## [1.0.0] — 2026-07-20

### Added
- `WatchtowerClient` — client principal avec retry exponentiel (3×) et injection auth
- `SourcesEndpoint` — tous les endpoints : `list`, `get`, `popular`, `latest`, `search`, `detail`, `videos`, `pages`, `filters`
- `WatchtowerPaginator` — pagination automatique via `pages()`, `items()`, `collect()`
- `PaginateEndpoint` — namespace `client.sources.paginate.popular/latest/search`
- Modèles typés : `Source`, `FeedItem`, `ItemsPage`, `ContentDetail`, `Chapter`, `VideoStream`, `MangaPage`, `Filter`
- `ItemType` enum : `manga`, `novel`, `video`, `music`
- `copyWith`, `==`, `hashCode` sur tous les modèles
- `WatchtowerApiException` (4xx/5xx) et `WatchtowerNetworkException` (réseau)
- Support auth `X-Api-Key` header et `Bearer` token
- Tests unitaires complets avec `MockClient`
- Exemple d'utilisation dans `example/main.dart`

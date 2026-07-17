# watchtower_client

Client Dart officiel pour l'[API REST Watchtower](https://github.com/ferelking242/watchtower).

Supporte les deux modes serveur :
- **Embarqué** : Dart/shelf sur port 4567 (app Flutter installée sur l'appareil)
- **Headless** : Node.js/Express en cloud (Railway, Render, Docker…)

---

## Installation

```yaml
# pubspec.yaml
dependencies:
  watchtower_client:
    git:
      url: https://github.com/ferelking242/watchtower-sdk-dart.git
      ref: main
```

---

## Usage rapide

```dart
import 'package:watchtower_client/watchtower_client.dart';

void main() async {
  final client = WatchtowerClient(
    url: 'https://mon-serveur.railway.app',
    apiKey: 'mysecretkey', // optionnel si serveur sans API_KEY
  );

  // Health check
  final ok = await client.ping();
  print('Serveur OK: $ok');

  // Lister les sources
  final sources = await client.sources.list();
  for (final s in sources) {
    print('${s.name} (${s.lang}) — ${s.itemType}');
  }

  // Contenus populaires
  final page = await client.sources.popular('local', page: 1);
  for (final item in page.items) {
    print('${item.name} — ${item.link}');
  }

  // Recherche
  final results = await client.sources.search('local', 'attack on titan');

  // Détail (chapitres / épisodes)
  final detail = await client.sources.detail('local', url: 'https://…');
  print('${detail.episodes.length} épisodes');

  // Streams vidéo
  final streams = await client.sources.videos('local', url: 'https://…');
  for (final v in streams) {
    print('${v.quality}: ${v.url}');
  }

  // Pages manga
  final pages = await client.sources.pages('local', url: 'https://…');

  // Filtres de recherche
  final filters = await client.sources.filters('local');

  client.close();
}
```

---

## API complète

### `WatchtowerClient`

| Méthode | Description |
|---|---|
| `ping()` | Vérifie que le serveur répond. Retourne `bool`. |
| `sources.list()` | Liste toutes les sources disponibles. |
| `sources.get(id)` | Récupère une source par son identifiant. |
| `sources.popular(id, {page})` | Contenus populaires, paginés. |
| `sources.latest(id, {page})` | Dernières mises à jour, paginées. |
| `sources.search(id, query, {page})` | Recherche dans une source. |
| `sources.detail(id, {url})` | Détail d'un contenu avec chapitres/épisodes. |
| `sources.videos(id, {url})` | Streams vidéo d'un épisode. |
| `sources.pages(id, {url})` | Pages d'un chapitre manga. |
| `sources.filters(id)` | Filtres de recherche avancée. |
| `close()` | Libère les ressources HTTP. |

### Gestion d'erreurs

```dart
try {
  final sources = await client.sources.list();
} on WatchtowerApiException catch (e) {
  // Erreur HTTP (401, 403, 404, 500…)
  print('API error ${e.statusCode}: ${e.message}');
} on WatchtowerNetworkException catch (e) {
  // Réseau inaccessible après N retries
  print('Network error: ${e.message}');
}
```

| Exception | Déclenchée quand |
|---|---|
| `WatchtowerApiException` | Serveur répond avec un code 4xx/5xx |
| `WatchtowerNetworkException` | Réseau inaccessible après N tentatives |

### Retry automatique

Par défaut, le client retente 3 fois avec un backoff exponentiel (300ms → 600ms → 1200ms) en cas d'erreur réseau. Les erreurs 4xx ne sont jamais retentées.

```dart
final client = WatchtowerClient(
  url: '…',
  maxRetries: 5,          // 5 tentatives
  timeout: Duration(seconds: 30),
);
```

---

## Documentation de l'API

La spec OpenAPI complète est disponible dans le repo principal :
[watchtower/server/openapi.yaml](https://github.com/ferelking242/watchtower/blob/main/server/openapi.yaml)

Un Swagger UI interactif est accessible sur votre serveur déployé à `GET /docs`.

---

## Développement

```bash
dart pub get
dart test
```

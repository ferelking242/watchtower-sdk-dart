import 'package:http/http.dart' as http;
import 'http_client.dart';
import 'endpoints/sources_endpoint.dart';

/// Client principal de l'API Watchtower.
///
/// Supporte les deux modes serveur (embarqué Dart/shelf et headless Node.js).
///
/// ```dart
/// final client = WatchtowerClient(
///   url: 'https://mon-serveur.railway.app',
///   apiKey: 'mysecretkey',
/// );
///
/// // Health check
/// final ok = await client.ping();
///
/// // Lister les sources
/// final sources = await client.sources.list();
///
/// // Contenus populaires
/// final page = await client.sources.popular('local', page: 1);
/// for (final item in page.items) {
///   print('${item.name} — ${item.link}');
/// }
///
/// // Streams vidéo
/// final streams = await client.sources.videos('local', url: 'https://…');
///
/// // Toujours fermer quand on a terminé
/// client.close();
/// ```
class WatchtowerClient {
  late final WatchtowerHttpClient _http;
  late final SourcesEndpoint _sources;

  /// Crée un client Watchtower.
  ///
  /// - [url]        : URL de base du serveur (ex: `https://mon-app.railway.app`)
  /// - [apiKey]     : Clé API (optionnel si le serveur tourne sans `API_KEY`)
  /// - [timeout]    : Timeout par requête (défaut 15s)
  /// - [maxRetries] : Nombre de tentatives en cas d'erreur réseau (défaut 3)
  /// - [httpClient] : Client HTTP personnalisé (utile pour les tests)
  WatchtowerClient({
    required String url,
    String? apiKey,
    Duration timeout = const Duration(seconds: 15),
    int maxRetries = 3,
    http.Client? httpClient,
  }) {
    _http = WatchtowerHttpClient(
      baseUrl: url,
      apiKey: apiKey,
      timeout: timeout,
      maxRetries: maxRetries,
      inner: httpClient,
    );
    _sources = SourcesEndpoint(_http);
  }

  /// Toutes les opérations sur les sources et leur contenu.
  SourcesEndpoint get sources => _sources;

  /// Vérifie que le serveur répond.
  ///
  /// Retourne `true` si le serveur est opérationnel, `false` sinon.
  /// Cette route ne nécessite pas de clé API.
  Future<bool> ping() async {
    try {
      final data = await _http.get('/api/ping');
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// Libère les ressources du client HTTP sous-jacent.
  ///
  /// À appeler quand le client n'est plus utilisé (fin d'app, tearDown de test…).
  void close() => _http.close();
}

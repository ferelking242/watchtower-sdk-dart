import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

/// Client HTTP interne avec retry exponentiel et injection automatique du header auth.
class WatchtowerHttpClient {
  final String baseUrl;
  final String? apiKey;
  final Duration timeout;
  final int maxRetries;
  final http.Client _inner;

  WatchtowerHttpClient({
    required this.baseUrl,
    this.apiKey,
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 3,
    http.Client? inner,
  }) : _inner = inner ?? http.Client();

  /// Libère les ressources du client HTTP sous-jacent.
  void close() => _inner.close();

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (apiKey != null && apiKey!.isNotEmpty) 'X-Api-Key': apiKey!,
      };

  /// Effectue un GET avec retry exponentiel.
  ///
  /// Lance [WatchtowerNetworkException] si le réseau est inaccessible après
  /// [maxRetries] tentatives, et [WatchtowerApiException] si le serveur retourne
  /// un code d'erreur HTTP (4xx, 5xx).
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String?> queryParams = const {},
  }) async {
    final uri = _buildUri(path, queryParams);
    Object? lastError;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await _inner
            .get(uri, headers: _defaultHeaders)
            .timeout(timeout);

        return _handleResponse(response, path);
      } on WatchtowerApiException {
        // Ne pas retenter les erreurs 4xx — elles ne changeront pas.
        rethrow;
      } catch (e) {
        lastError = e;
        if (attempt < maxRetries - 1) {
          final delay = Duration(milliseconds: 300 * (1 << attempt)); // 300ms, 600ms, 1200ms
          await Future.delayed(delay);
        }
      }
    }

    throw WatchtowerNetworkException(
      'Failed to reach $path after $maxRetries attempts',
      cause: lastError,
    );
  }

  Uri _buildUri(String path, Map<String, String?> queryParams) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final clean = path.startsWith('/') ? path : '/$path';
    final filtered = Map.fromEntries(
      queryParams.entries.where((e) => e.value != null),
    ).cast<String, String>();
    return Uri.parse('$base$clean').replace(queryParameters: filtered.isEmpty ? null : filtered);
  }

  Map<String, dynamic> _handleResponse(http.Response response, String path) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        // Certains endpoints retournent une liste directement — on la wrappe
        return {'_list': decoded};
      } catch (e) {
        throw WatchtowerNetworkException('Invalid JSON from $path: $e');
      }
    }

    String errorMessage;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      errorMessage = (body['error'] as String?) ?? response.reasonPhrase ?? 'Unknown error';
    } catch (_) {
      errorMessage = response.reasonPhrase ?? 'HTTP ${response.statusCode}';
    }

    throw WatchtowerApiException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }
}

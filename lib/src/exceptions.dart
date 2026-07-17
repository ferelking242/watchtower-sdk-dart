/// Exception de base pour toutes les erreurs du client Watchtower.
sealed class WatchtowerException implements Exception {
  final String message;
  const WatchtowerException(this.message);
  @override
  String toString() => 'WatchtowerException: $message';
}

/// Erreur réseau (timeout, DNS, connexion refusée…).
final class WatchtowerNetworkException extends WatchtowerException {
  final Object? cause;
  const WatchtowerNetworkException(super.message, {this.cause});

  @override
  String toString() =>
      'WatchtowerNetworkException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Erreur retournée par l'API (4xx, 5xx).
final class WatchtowerApiException extends WatchtowerException {
  /// Code HTTP reçu (401, 403, 404, 500…).
  final int statusCode;

  const WatchtowerApiException(super.message, {required this.statusCode});

  @override
  String toString() => 'WatchtowerApiException[$statusCode]: $message';
}

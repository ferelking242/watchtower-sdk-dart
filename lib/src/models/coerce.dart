/// Tolerant JSON coercion.
///
/// The Watchtower server serialises Isar entities: `id` is an int, `itemType`
/// is an enum *name*, `hasNextPage` is a real bool, `chapterNumber` may be an
/// int or a string. Casting those with `as String` / `as int` throws
/// `type 'int' is not a subtype of type 'String' in type cast` and kills the
/// whole request, so every model goes through these helpers instead.
library;

/// Returns [value] as a `String`, stringifying numbers and booleans.
/// `null` becomes [fallback].
String coerceString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

/// Returns [value] as a `String?`, stringifying numbers and booleans.
String? coerceStringOrNull(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

/// Returns [value] as an `int`, accepting `num` and numeric strings.
int coerceInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

/// Returns [value] as a `double`, accepting `num` and numeric strings.
double? coerceDoubleOrNull(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

/// Returns [value] as a `bool`. Accepts `true/false`, `1/0`, `"true"/"1"`.
bool coerceBool(Object? value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final text = value.trim().toLowerCase();
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;
  }
  return fallback;
}

/// Returns [value] as a `List<String>`, dropping nulls and stringifying items.
/// A single scalar becomes a one-element list so `"genre": "action"` works.
List<String> coerceStringList(Object? value) {
  if (value == null) return const [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => e is String ? e : e.toString())
        .toList(growable: false);
  }
  if (value is String) {
    return value.isEmpty ? const [] : [value];
  }
  return [value.toString()];
}

/// Returns [value] as a JSON object, or `null` when it is anything else.
Map<String, dynamic>? coerceMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return null;
}

/// Returns [value] as a list of JSON objects, skipping malformed entries.
List<Map<String, dynamic>> coerceMapList(Object? value) {
  if (value is! List) return const [];
  return value.map(coerceMap).whereType<Map<String, dynamic>>().toList();
}

/// Returns [value] as `Map<String, String>`, stringifying every value.
Map<String, String> coerceStringMap(Object? value) {
  final map = coerceMap(value);
  if (map == null) return const {};
  return map.map((k, v) => MapEntry(k, v == null ? '' : v.toString()));
}

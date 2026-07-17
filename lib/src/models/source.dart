/// Type de contenu exposé par une source.
enum ItemType {
  manga(0),
  novel(1),
  video(2),
  music(3);

  const ItemType(this.value);
  final int value;

  static ItemType fromInt(int v) =>
      ItemType.values.firstWhere((e) => e.value == v, orElse: () => ItemType.video);
}

/// Source d'extension Watchtower (site ou catalogue).
class Source {
  final String id;
  final String name;
  final String lang;
  final String? baseUrl;
  final String? sourceCodeUrl;
  final String? iconUrl;
  final bool isNsfw;
  final ItemType itemType;
  final bool isManga;
  final String? version;
  final bool supportsLatest;

  const Source({
    required this.id,
    required this.name,
    required this.lang,
    this.baseUrl,
    this.sourceCodeUrl,
    this.iconUrl,
    this.isNsfw = false,
    this.itemType = ItemType.video,
    this.isManga = false,
    this.version,
    this.supportsLatest = true,
  });

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        id: json['id']?.toString() ?? '',
        name: (json['name'] as String?) ?? '',
        lang: (json['lang'] as String?) ?? '',
        baseUrl: json['baseUrl'] as String?,
        sourceCodeUrl: json['sourceCodeUrl'] as String?,
        iconUrl: json['iconUrl'] as String?,
        isNsfw: (json['isNsfw'] as bool?) ?? false,
        itemType: ItemType.fromInt((json['itemType'] as num?)?.toInt() ?? 2),
        isManga: (json['isManga'] as bool?) ?? false,
        version: json['version'] as String?,
        supportsLatest: (json['supportsLatest'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lang': lang,
        if (baseUrl != null) 'baseUrl': baseUrl,
        if (sourceCodeUrl != null) 'sourceCodeUrl': sourceCodeUrl,
        if (iconUrl != null) 'iconUrl': iconUrl,
        'isNsfw': isNsfw,
        'itemType': itemType.value,
        'isManga': isManga,
        if (version != null) 'version': version,
        'supportsLatest': supportsLatest,
      };

  @override
  String toString() => 'Source(id: $id, name: $name, lang: $lang, type: $itemType)';
}

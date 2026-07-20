/// Type de contenu exposé par une source.
enum ItemType {
  /// Manga / bande dessinée (itemType = 0)
  manga(0),

  /// Roman (itemType = 1)
  novel(1),

  /// Vidéo / anime (itemType = 2)
  video(2),

  /// Musique (itemType = 3)
  music(3);

  final int value;
  const ItemType(this.value);

  static ItemType fromInt(int? v) =>
      ItemType.values.firstWhere((e) => e.value == v, orElse: () => ItemType.manga);
}

/// Source d'extensions disponible sur le serveur Watchtower.
class Source {
  /// Identifiant unique (slug) de la source.
  final String id;

  /// Nom affiché.
  final String name;

  /// Code langue ISO 639-1 (ex: `fr`, `en`, `ja`).
  final String lang;

  /// URL de base du site source.
  final String? baseUrl;

  /// URL du fichier JS de l'extension.
  final String? sourceCodeUrl;

  /// URL de l'icône.
  final String? iconUrl;

  /// Si `true`, la source est filtrée de l'API publique.
  final bool isNsfw;

  /// Type de contenu de cette source.
  final ItemType itemType;

  /// Si `true`, la source est une source de manga.
  final bool isManga;

  /// Version de l'extension.
  final String? version;

  /// Si `true`, la source supporte `getLatestUpdates`.
  final bool supportsLatest;

  const Source({
    required this.id,
    required this.name,
    required this.lang,
    this.baseUrl,
    this.sourceCodeUrl,
    this.iconUrl,
    this.isNsfw = false,
    this.itemType = ItemType.manga,
    this.isManga = false,
    this.version,
    this.supportsLatest = true,
  });

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        id: (json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        lang: (json['lang'] ?? '') as String,
        baseUrl: json['baseUrl'] as String?,
        sourceCodeUrl: json['sourceCodeUrl'] as String?,
        iconUrl: json['iconUrl'] as String?,
        isNsfw: (json['isNsfw'] as bool?) ?? false,
        itemType: ItemType.fromInt(json['itemType'] as int?),
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

  Source copyWith({
    String? id,
    String? name,
    String? lang,
    String? baseUrl,
    String? sourceCodeUrl,
    String? iconUrl,
    bool? isNsfw,
    ItemType? itemType,
    bool? isManga,
    String? version,
    bool? supportsLatest,
  }) =>
      Source(
        id: id ?? this.id,
        name: name ?? this.name,
        lang: lang ?? this.lang,
        baseUrl: baseUrl ?? this.baseUrl,
        sourceCodeUrl: sourceCodeUrl ?? this.sourceCodeUrl,
        iconUrl: iconUrl ?? this.iconUrl,
        isNsfw: isNsfw ?? this.isNsfw,
        itemType: itemType ?? this.itemType,
        isManga: isManga ?? this.isManga,
        version: version ?? this.version,
        supportsLatest: supportsLatest ?? this.supportsLatest,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Source && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Source(id: $id, name: $name, lang: $lang, type: $itemType)';
}

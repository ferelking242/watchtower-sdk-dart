/// Filtre de recherche avancée retourné par `/filters`.
///
/// La structure exacte varie selon l'extension (SelectFilter, TextFilter, etc.)
/// donc le modèle est volontairement permissif.
class Filter {
  final String? type;
  final String? name;
  final dynamic value;
  final List<String> options;

  const Filter({
    this.type,
    this.name,
    this.value,
    this.options = const [],
  });

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
        type: json['type'] as String?,
        name: json['name'] as String?,
        value: json['value'],
        options: (json['options'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (name != null) 'name': name,
        if (value != null) 'value': value,
        if (options.isNotEmpty) 'options': options,
      };

  @override
  String toString() => 'Filter(type: $type, name: $name)';
}

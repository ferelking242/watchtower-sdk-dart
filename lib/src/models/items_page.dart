import 'feed_item.dart';

/// Page de résultats (popular / latest / search).
class ItemsPage {
  final List<FeedItem> items;
  final bool hasNextPage;

  const ItemsPage({required this.items, required this.hasNextPage});

  factory ItemsPage.fromJson(Map<String, dynamic> json) => ItemsPage(
        items: ((json['mangas'] ?? json['items']) as List<dynamic>? ?? [])
            .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasNextPage: (json['hasNextPage'] as bool?) ?? false,
      );

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  @override
  String toString() =>
      'ItemsPage(${items.length} items, hasNextPage: $hasNextPage)';
}

import 'coerce.dart';
import 'feed_item.dart';

/// Page de résultats (popular / latest / search).
class ItemsPage {
  final List<FeedItem> items;
  final bool hasNextPage;

  const ItemsPage({required this.items, required this.hasNextPage});

  factory ItemsPage.fromJson(Map<String, dynamic> json) => ItemsPage(
        items: coerceMapList(json['mangas'] ?? json['items'] ?? json['list'])
            .map(FeedItem.fromJson)
            .toList(),
        hasNextPage: coerceBool(json['hasNextPage']),
      );

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  @override
  String toString() =>
      'ItemsPage(${items.length} items, hasNextPage: $hasNextPage)';
}

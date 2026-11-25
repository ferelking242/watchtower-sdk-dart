import 'package:test/test.dart';
import 'package:watchtower_client/watchtower_client.dart';

/// The Watchtower server serialises Isar entities: `id` is an int and
/// `itemType` is the enum *name*. Parsing those used to throw
/// `type 'int' is not a subtype of type 'String' in type cast`, which surfaced
/// as "Connexion impossible" in every client.
void main() {
  group('Source.fromJson', () {
    test('accepts the payload the Watchtower server actually sends', () {
      final source = Source.fromJson({
        'id': 7,
        'name': 'RedGifs',
        'lang': 'en',
        'baseUrl': 'https://redgifs.com',
        'itemType': 'video',
        'isNsfw': true,
        'isPinned': false,
      });

      expect(source.id, '7');
      expect(source.name, 'RedGifs');
      expect(source.lang, 'en');
      expect(source.itemType, ItemType.video);
      expect(source.isNsfw, isTrue);
      expect(source.isManga, isFalse);
    });

    test('accepts numeric item types and numeric strings', () {
      expect(
        Source.fromJson({'id': 1, 'itemType': 2}).itemType,
        ItemType.video,
      );
      expect(
        Source.fromJson({'id': '2', 'itemType': '2'}).itemType,
        ItemType.video,
      );
      expect(Source.fromJson({'id': 3}).itemType, ItemType.manga);
    });

    test('survives null and unexpected types', () {
      final source = Source.fromJson({
        'id': null,
        'name': null,
        'lang': 42,
        'iconUrl': 0,
        'isNsfw': 1,
      });

      expect(source.id, '');
      expect(source.name, '');
      expect(source.lang, '42');
      expect(source.iconUrl, '0');
      expect(source.isNsfw, isTrue);
    });
  });

  group('ItemsPage.fromJson', () {
    test('parses the mangas key with int-ish fields', () {
      final page = ItemsPage.fromJson({
        'mangas': [
          {
            'link': 'https://example.org/watch/1',
            'name': 'Clip',
            'imageUrl': 12,
            'genre': ['action', 3],
          },
          'not-a-map',
        ],
        'hasNextPage': 1,
      });

      expect(page.items, hasLength(1));
      expect(page.items.first.name, 'Clip');
      expect(page.items.first.imageUrl, '12');
      expect(page.items.first.genre, ['action', '3']);
      expect(page.hasNextPage, isTrue);
    });
  });

  group('ContentDetail.fromJson', () {
    test('parses episodes with numeric chapter numbers', () {
      final detail = ContentDetail.fromJson({
        'name': 'Show',
        'episodes': [
          {'url': 'https://x/1', 'name': 1, 'chapterNumber': '2.5'},
        ],
      });

      expect(detail.name, 'Show');
      expect(detail.episodes, hasLength(1));
      expect(detail.episodes.first.name, '1');
      expect(detail.episodes.first.chapterNumber, 2.5);
    });
  });

  group('VideoStream.fromJson', () {
    test('stringifies header values', () {
      final stream = VideoStream.fromJson({
        'url': 'https://cdn/x.m3u8',
        'quality': 'auto',
        'headers': {'Referer': 1, 'User-Agent': 'x'},
        'isM3U8': 1,
      });

      expect(stream.headers, {'Referer': '1', 'User-Agent': 'x'});
      expect(stream.isM3U8, isTrue);
    });
  });
}

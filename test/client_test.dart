import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:watchtower_client/watchtower_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

MockClient _mockClient(Map<String, dynamic> body, {int status = 200}) =>
    MockClient((req) async => http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'}));

MockClient _mockSequence(List<Map<String, dynamic>> responses) {
  int call = 0;
  return MockClient((req) async {
    final body = responses[call.clamp(0, responses.length - 1)];
    call++;
    return http.Response(jsonEncode(body), 200,
        headers: {'content-type': 'application/json'});
  });
}

WatchtowerClient _client(http.Client mock) => WatchtowerClient(
      url: 'http://localhost:8080',
      apiKey: 'test-key',
      httpClient: mock,
    );

// ─────────────────────────────────────────────────────────────────────────────
// ping
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('ping', () {
    test('returns true when server responds ok', () async {
      final client = _client(_mockClient({'status': 'ok', 'version': '1.0.0'}));
      expect(await client.ping(), isTrue);
      client.close();
    });

    test('returns false on network error', () async {
      final client = _client(MockClient((_) async => throw Exception('timeout')));
      expect(await client.ping(), isFalse);
      client.close();
    });
  });

  // ── sources.list ───────────────────────────────────────────────────────────
  group('sources.list', () {
    test('parses sources array', () async {
      final mock = _mockClient({
        'sources': [
          {'id': 'local', 'name': 'Watchtower Local', 'lang': 'fr', 'itemType': 2},
          {'id': 'cr', 'name': 'Crunchyroll', 'lang': 'en', 'itemType': 2},
        ]
      });
      final client = _client(mock);
      final sources = await client.sources.list();
      expect(sources.length, equals(2));
      expect(sources.first.id, equals('local'));
      expect(sources.first.itemType, equals(ItemType.video));
      client.close();
    });

    test('throws WatchtowerApiException on 401', () async {
      final client = _client(MockClient((_) async =>
          http.Response(jsonEncode({'error': 'Unauthorized'}), 401,
              headers: {'content-type': 'application/json'})));
      expect(
        () => client.sources.list(),
        throwsA(isA<WatchtowerApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
      client.close();
    });
  });

  // ── sources.popular ────────────────────────────────────────────────────────
  group('sources.popular', () {
    test('parses ItemsPage correctly', () async {
      final mock = _mockClient({
        'mangas': [
          {'link': 'https://example.com/1', 'name': 'One Piece', 'imageUrl': 'https://img.com/1.jpg'},
          {'link': 'https://example.com/2', 'name': 'Naruto'},
        ],
        'hasNextPage': true,
      });
      final client = _client(mock);
      final page = await client.sources.popular('local');
      expect(page.items.length, equals(2));
      expect(page.hasNextPage, isTrue);
      expect(page.items.first.name, equals('One Piece'));
      client.close();
    });

    test('sends page query param', () async {
      String? capturedUrl;
      final mock = MockClient((req) async {
        capturedUrl = req.url.toString();
        return http.Response(
            jsonEncode({'mangas': [], 'hasNextPage': false}), 200,
            headers: {'content-type': 'application/json'});
      });
      final client = _client(mock);
      await client.sources.popular('local', page: 3);
      expect(capturedUrl, contains('page=3'));
      client.close();
    });
  });

  // ── sources.search ─────────────────────────────────────────────────────────
  group('sources.search', () {
    test('sends query param', () async {
      String? capturedUrl;
      final mock = MockClient((req) async {
        capturedUrl = req.url.toString();
        return http.Response(
            jsonEncode({'mangas': [], 'hasNextPage': false}), 200,
            headers: {'content-type': 'application/json'});
      });
      final client = _client(mock);
      await client.sources.search('local', 'demon slayer');
      expect(capturedUrl, contains('q=demon+slayer'));
      client.close();
    });
  });

  // ── sources.detail ─────────────────────────────────────────────────────────
  group('sources.detail', () {
    test('parses ContentDetail with chapters', () async {
      final mock = _mockClient({
        'name': 'Attack on Titan',
        'description': 'Titans attack',
        'chapters': [
          {'url': 'https://example.com/ch1', 'name': 'Chapter 1', 'chapterNumber': 1.0},
        ],
        'episodes': [],
      });
      final client = _client(mock);
      final detail = await client.sources.detail('local', url: 'https://example.com/aot');
      expect(detail.name, equals('Attack on Titan'));
      expect(detail.chapters.length, equals(1));
      expect(detail.isManga, isTrue);
      expect(detail.isVideo, isFalse);
      client.close();
    });
  });

  // ── sources.videos ─────────────────────────────────────────────────────────
  group('sources.videos', () {
    test('parses VideoStream list', () async {
      final mock = _mockClient({
        'videos': [
          {'url': 'https://cdn.example.com/1080.m3u8', 'quality': '1080p', 'isM3U8': true},
          {'url': 'https://cdn.example.com/720.m3u8', 'quality': '720p', 'isM3U8': true},
        ]
      });
      final client = _client(mock);
      final streams = await client.sources.videos('local', url: 'https://example.com/ep1');
      expect(streams.length, equals(2));
      expect(streams.first.quality, equals('1080p'));
      expect(streams.first.isM3U8, isTrue);
      client.close();
    });
  });

  // ── Pagination ─────────────────────────────────────────────────────────────
  group('WatchtowerPaginator', () {
    test('stops when hasNextPage is false', () async {
      final mock = _mockSequence([
        {'mangas': [{'link': '/1', 'name': 'A'}], 'hasNextPage': true},
        {'mangas': [{'link': '/2', 'name': 'B'}], 'hasNextPage': false},
      ]);
      final client = _client(mock);
      final items = await client.sources.paginate.popular('local').collect();
      expect(items.length, equals(2));
      client.close();
    });

    test('collect respects maxPages', () async {
      final mock = MockClient((req) async => http.Response(
          jsonEncode({'mangas': [{'link': '/x', 'name': 'X'}], 'hasNextPage': true}),
          200,
          headers: {'content-type': 'application/json'}));
      final client = _client(mock);
      final items = await client.sources.paginate.popular('local').collect(maxPages: 2);
      expect(items.length, equals(2));
      client.close();
    });

    test('items() stream emits all items across pages', () async {
      final mock = _mockSequence([
        {'mangas': [{'link': '/1', 'name': 'A'}, {'link': '/2', 'name': 'B'}], 'hasNextPage': true},
        {'mangas': [{'link': '/3', 'name': 'C'}], 'hasNextPage': false},
      ]);
      final client = _client(mock);
      final names = <String>[];
      await for (final item in client.sources.paginate.popular('local').items()) {
        names.add(item.name);
      }
      expect(names, equals(['A', 'B', 'C']));
      client.close();
    });
  });

  // ── Model equality ─────────────────────────────────────────────────────────
  group('Model equality', () {
    test('Source == by id', () {
      final a = Source(id: 'local', name: 'A', lang: 'fr');
      final b = Source(id: 'local', name: 'B', lang: 'en');
      expect(a, equals(b));
    });

    test('FeedItem == by link', () {
      final a = FeedItem(link: 'https://x.com/1', name: 'A');
      final b = FeedItem(link: 'https://x.com/1', name: 'B');
      expect(a, equals(b));
    });

    test('Source.copyWith preserves unchanged fields', () {
      final s = Source(id: 'x', name: 'X', lang: 'fr', version: '1.0');
      final s2 = s.copyWith(name: 'Y');
      expect(s2.id, equals('x'));
      expect(s2.lang, equals('fr'));
      expect(s2.name, equals('Y'));
      expect(s2.version, equals('1.0'));
    });
  });
}

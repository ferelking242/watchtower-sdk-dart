import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:watchtower_client/watchtower_client.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Crée un MockClient qui répond avec le JSON donné et le code HTTP donné.
http.Client mockJson(Object body, {int status = 200}) {
  return MockClient((request) async {
    return http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'});
  });
}

/// Crée un WatchtowerClient avec le MockClient injecté.
WatchtowerClient makeClient(http.Client mock) => WatchtowerClient(
      url: 'http://localhost:8080',
      apiKey: 'testkey',
      httpClient: mock,
      maxRetries: 1,
    );

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('WatchtowerClient.ping', () {
    test('retourne true quand le serveur répond ok', () async {
      final client = makeClient(mockJson({'status': 'ok', 'version': '0.1.0'}));
      expect(await client.ping(), isTrue);
      client.close();
    });

    test('retourne false en cas d'erreur réseau', () async {
      final client = makeClient(MockClient((_) async => throw Exception('network')));
      expect(await client.ping(), isFalse);
      client.close();
    });
  });

  group('sources.list', () {
    test('désérialise la liste de sources', () async {
      final mock = mockJson({
        'sources': [
          {
            'id': 'local',
            'name': 'Watchtower Local',
            'lang': 'fr',
            'isNsfw': false,
            'itemType': 2,
          }
        ]
      });
      final client = makeClient(mock);
      final sources = await client.sources.list();
      expect(sources, hasLength(1));
      expect(sources.first.id, 'local');
      expect(sources.first.itemType, ItemType.video);
      client.close();
    });

    test('lance WatchtowerApiException sur 401', () async {
      final client = makeClient(
          mockJson({'error': 'Missing or invalid API key'}, status: 401));
      expect(
        () => client.sources.list(),
        throwsA(isA<WatchtowerApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
      client.close();
    });
  });

  group('sources.popular', () {
    test('désérialise une ItemsPage', () async {
      final mock = mockJson({
        'mangas': [
          {'link': 'https://ex.com/1', 'name': 'Titre 1', 'imageUrl': 'https://img.com/1.jpg'},
          {'link': 'https://ex.com/2', 'name': 'Titre 2'},
        ],
        'hasNextPage': true,
      });
      final client = makeClient(mock);
      final page = await client.sources.popular('local', page: 1);
      expect(page.items, hasLength(2));
      expect(page.hasNextPage, isTrue);
      expect(page.items.first.name, 'Titre 1');
      client.close();
    });
  });

  group('sources.videos', () {
    test('désérialise les VideoStream', () async {
      final mock = mockJson({
        'videos': [
          {'url': 'https://cdn.com/video.m3u8', 'quality': '1080p', 'isM3U8': true},
          {'url': 'https://cdn.com/video_720.mp4', 'quality': '720p'},
        ]
      });
      final client = makeClient(mock);
      final streams = await client.sources.videos('local', url: 'https://ex.com/ep1');
      expect(streams, hasLength(2));
      expect(streams.first.quality, '1080p');
      expect(streams.first.isM3U8, isTrue);
      client.close();
    });
  });

  group('sources.detail', () {
    test('désérialise ContentDetail avec épisodes', () async {
      final mock = mockJson({
        'name': 'Attack on Titan',
        'episodes': [
          {'url': 'https://ex.com/ep1', 'name': 'Episode 1'},
          {'url': 'https://ex.com/ep2', 'name': 'Episode 2'},
        ],
      });
      final client = makeClient(mock);
      final detail = await client.sources.detail('local', url: 'https://ex.com/aot');
      expect(detail.name, 'Attack on Titan');
      expect(detail.episodes, hasLength(2));
      expect(detail.allEpisodes.first.name, 'Episode 1');
      client.close();
    });
  });

  group('sources.pages', () {
    test('désérialise les MangaPage', () async {
      final mock = mockJson({
        'pages': [
          {'page': 0, 'url': 'https://img.com/p0.jpg'},
          {'page': 1, 'url': 'https://img.com/p1.jpg'},
        ]
      });
      final client = makeClient(mock);
      final pages = await client.sources.pages('local', url: 'https://ex.com/ch1');
      expect(pages, hasLength(2));
      expect(pages.first.page, 0);
      client.close();
    });
  });

  group('WatchtowerNetworkException', () {
    test('est lancée après épuisement des retries', () async {
      int calls = 0;
      final client = WatchtowerClient(
        url: 'http://localhost:8080',
        apiKey: 'key',
        maxRetries: 2,
        httpClient: MockClient((_) async {
          calls++;
          throw Exception('connection refused');
        }),
      );
      await expectLater(
        client.sources.list(),
        throwsA(isA<WatchtowerNetworkException>()),
      );
      expect(calls, 2);
      client.close();
    });
  });
}

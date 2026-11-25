import 'coerce.dart';

/// Stream vidéo retourné par `/videos`.
class VideoStream {
  /// URL directe du stream (HLS m3u8, MP4, DASH mpd…).
  final String url;

  /// Label de qualité affiché à l'utilisateur.
  final String quality;

  /// Headers HTTP supplémentaires requis pour lire le stream (Referer, etc.).
  final Map<String, String> headers;

  final bool isM3U8;
  final bool isMPD;

  const VideoStream({
    required this.url,
    required this.quality,
    this.headers = const {},
    this.isM3U8 = false,
    this.isMPD = false,
  });

  factory VideoStream.fromJson(Map<String, dynamic> json) => VideoStream(
        url: coerceString(json['url']),
        quality: coerceString(json['quality']),
        headers: coerceStringMap(json['headers']),
        isM3U8: coerceBool(json['isM3U8']),
        isMPD: coerceBool(json['isMPD']),
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'quality': quality,
        if (headers.isNotEmpty) 'headers': headers,
        'isM3U8': isM3U8,
        'isMPD': isMPD,
      };

  @override
  String toString() => 'VideoStream(quality: $quality, url: ${url.substring(0, url.length.clamp(0, 60))}…)';
}

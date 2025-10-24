import 'package:audio_service/audio_service.dart';

class Song {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String albumCover;
  final String url;
  final Duration duration;
  final String lyrics;
  final String lrcLyrics;
  final bool isVip;
  final String hash;

  Song({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.albumCover,
    required this.url,
    required this.duration,
    this.lyrics = '',
    this.lrcLyrics = '',
    this.isVip = false,
    this.hash = '',
  });

  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      album: album,
      title: name,
      artist: artist,
      artUri: Uri.parse(albumCover),
      duration: duration,
      extras: {
        'url': url,
        'lyrics': lyrics,
        'lrc_lyrics': lrcLyrics,
        'is_vip': isVip,
        'hash': hash,
      },
    );
  }

  static Song fromMediaItem(MediaItem mediaItem) {
    return Song(
      id: mediaItem.id,
      name: mediaItem.title,
      artist: mediaItem.artist ?? '',
      album: mediaItem.album ?? '',
      albumCover: mediaItem.artUri?.toString() ?? '',
      url: mediaItem.extras?['url'] ?? '',
      duration: mediaItem.duration ?? Duration.zero,
      lyrics: mediaItem.extras?['lyrics'] ?? '',
      lrcLyrics: mediaItem.extras?['lrc_lyrics'] ?? '',
      isVip: mediaItem.extras?['is_vip'] ?? false,
      hash: mediaItem.extras?['hash'] ?? '',
    );
  }
}
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../models/song.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  
  // Playlist management
  List<MediaItem> _playlist = [];
  int? _currentIndex;

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    // Handle playback events
    _player.playbackEventStream.listen((event) {
      // Update playback state
      playbackState.add(_mapState(_player.playerState));
    }, onError: (error, stackTrace) {
      // Handle errors
      addError(error);
    });

    // Handle duration changes
    _player.durationStream.listen((duration) {
      var index = _currentIndex;
      if (index != null) {
        MediaItem? mediaItem = _playlist.length > index ? _playlist[index] : null;
        if (mediaItem != null) {
          mediaItem = mediaItem.copyWith(duration: duration);
          _playlist[index] = mediaItem;
        }
      }
      queue.add(_playlist);
    });

    // Handle position changes
    _player.positionStream.listen((position) {
      // Update position
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });
  }

  // Map player state to audio service state
  PlaybackState _mapState(PlayerState playerState) {
    return PlaybackState(
      processingState: _mapProcessingState(playerState.processingState),
      playing: playerState.playing,
      controls: [
        MediaControl.skipToPrevious,
        if (playerState.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1, 2],
    );
  }

  // Map processing state
  AudioProcessingState _mapProcessingState(ProcessingState processingState) {
    switch (processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _skip(1);

  @override
  Future<void> skipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    if (_playlist.isEmpty) return;
    int newIndex = (_currentIndex ?? 0) + offset;
    if (newIndex < 0 || newIndex >= _playlist.length) return;
    _currentIndex = newIndex;
    await _loadCurrentTrack();
  }

  Future<void> _loadCurrentTrack() async {
    if (_currentIndex != null && _playlist.isNotEmpty) {
      MediaItem mediaItem = _playlist[_currentIndex!];
      await _player.setAudioSource(ConcatenatingAudioSource(
        children: [
          AudioSource.uri(Uri.parse(mediaItem.extras!['url'])),
        ],
      ));
      queueTitle.add(mediaItem.title);
      queue.add(_playlist);
    }
  }

  // Load playlist
  Future<void> loadPlaylist(List<Song> songs) async {
    _playlist = songs.map((song) => song.toMediaItem()).toList();
    _currentIndex = 0;
    await _loadCurrentTrack();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> dispose() {
    _player.dispose();
    super.dispose();
  }
}
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  List<MediaItem> _queue = [];
  int? _currentIndex;

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    // 监听播放事件
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[event.processingState]!,
        playing: playing,
        updatePosition: event.updatePosition,
        bufferedPosition: event.bufferedPosition,
        speed: event.speed,
        queueIndex: event.currentIndex,
      ));
    });

    // 监听播放位置更新
    _player.positionStream.listen((position) {
      broadcastState();
    });

    // 监听播放速度变化
    _player.speedStream.listen((speed) {
      playbackState.add(playbackState.value.copyWith(speed: speed));
    });
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
    if (_queue.isEmpty) return;
    int newIndex = (_currentIndex ?? 0) + offset;
    if (newIndex < 0 || newIndex >= _queue.length) return;
    _currentIndex = newIndex;
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(_queue[_currentIndex!].extras!['url'])),
      initialIndex: _currentIndex,
    );
    queueTitle.add(_queue[_currentIndex!].title);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  // 加载播放队列
  Future<void> loadQueue(List<Song> songs) async {
    _queue = songs.map((song) => song.toMediaItem()).toList();
    if (_queue.isNotEmpty) {
      final audioSource = ConcatenatingAudioSource(
        children: _queue
            .map((item) => AudioSource.uri(Uri.parse(item.extras!['url']),
                tag: item))
            .toList(),
      );
      await _player.setAudioSource(audioSource);
      _currentIndex = 0;
      queue.add(_queue);
      queueTitle.add(_queue[0].title);
    }
  }

  // 播放特定歌曲
  Future<void> playSong(Song song) async {
    _queue = [song.toMediaItem()];
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(song.url), tag: song.toMediaItem()),
    );
    _currentIndex = 0;
    queue.add(_queue);
    queueTitle.add(_queue[0].title);
    play();
  }

  @override
  Future<void> dispose() {
    _player.dispose();
    super.dispose();
  }
}
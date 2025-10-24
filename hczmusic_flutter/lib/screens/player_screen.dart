import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/audio_player_handler.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final audioHandler = context.read<AudioPlayerHandler>();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      '现在播放',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // 专辑封面
            Expanded(
              flex: 2,
              child: StreamBuilder<MediaPlayerState?>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final currentMediaItem = playerState?.updatePosition.item;
                  
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: currentMediaItem != null
                            ? Image.network(
                                currentMediaItem.artUri.toString(),
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/default_album_cover.jpg',
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // 歌曲信息
            StreamBuilder<MediaPlayerState?>(
              stream: audioHandler.playbackState,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final currentMediaItem = playerState?.updatePosition.item;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        currentMediaItem?.title ?? '未知歌曲',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentMediaItem?.artist ?? '未知艺术家',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // 进度条
            StreamBuilder<PositionData>(
              stream: audioHandler.position,
              builder: (context, snapshot) {
                final positionData = snapshot.data ?? const PositionData.zero();
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Slider(
                        value: positionData.position.inMilliseconds.toDouble(),
                        min: 0.0,
                        max: positionData.duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          audioHandler.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            positionData.position.toString().split('.').first,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          Text(
                            positionData.duration.toString().split('.').first,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // 播放控制
            StreamBuilder<PlayerState>(
              stream: audioHandler.playerState,
              builder: (context, snapshot) {
                final playerState = snapshot.data?.processingState ?? AudioProcessingState.idle;
                final isPlaying = snapshot.data?.playing ?? false;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle),
                        onPressed: () => audioHandler.setShuffleMode(AudioServiceShuffleMode.all),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: () => audioHandler.skipToPrevious(),
                        iconSize: 36,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (playerState == AudioProcessingState.idle) {
                            // 如果没有播放列表，需要先设置播放列表
                          } else {
                            isPlaying ? audioHandler.pause() : audioHandler.play();
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: () => audioHandler.skipToNext(),
                        iconSize: 36,
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat),
                        onPressed: () => audioHandler.setRepeatMode(AudioServiceRepeatMode.none),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // 歌词
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '歌词功能将在后续版本中添加\n\n此功能需要从API获取歌词数据\n\n目前显示的是占位文本',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
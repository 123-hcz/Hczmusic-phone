import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return AudioServiceBuilder(
      builder: (context) {
        final AudioPlayerState? playerState = AudioService.maybePlaybackState;
        final MediaItem? currentMediaItem = AudioService.currentMediaItem;
        
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6a11cb),
                  Color(0xFF2575fc),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 顶部导航
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          '正在播放',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 专辑封面
                  if (currentMediaItem != null)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'album_art_${currentMediaItem.id}',
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.width * 0.7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: currentMediaItem.artUri?.toString() ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.music_note, size: 80),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.music_note, size: 80),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // 歌曲信息
                          Text(
                            currentMediaItem.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            currentMediaItem.artist ?? 'Unknown Artist',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // 进度条
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              children: [
                                StreamBuilder<Duration>(
                                  stream: AudioService.position,
                                  builder: (context, snapshot) {
                                    final duration = playerState?.duration ?? Duration.zero;
                                    final position = snapshot.data ?? Duration.zero;
                                    
                                    return Column(
                                      children: [
                                        Slider(
                                          value: position.inMilliseconds.toDouble(),
                                          max: duration.inMilliseconds.toDouble(),
                                          onChanged: (value) {
                                            AudioService.seekTo(Duration(milliseconds: value.toInt()));
                                          },
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.white38,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDuration(position),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(duration),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // 播放控制按钮
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shuffle, color: Colors.white, size: 30),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                                onPressed: () => AudioService.skipToPrevious(),
                              ),
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    playerState?.playing == true 
                                        ? Icons.pause 
                                        : Icons.play_arrow,
                                    color: Colors.black,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    if (playerState?.playing == true) {
                                      AudioService.pause();
                                    } else {
                                      AudioService.play();
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                                onPressed: () => AudioService.skipToNext(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.repeat, color: Colors.white, size: 30),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/player_screen.dart';

class PlayerControl extends StatelessWidget {
  final Function()? onTap;

  const PlayerControl({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AudioServiceBuilder(
      builder: (context) {
        final AudioPlayerState? playerState = AudioService.maybePlaybackState;
        final MediaItem? currentMediaItem = AudioService.currentMediaItem;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // 专辑封面
                if (currentMediaItem != null)
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        imageUrl: currentMediaItem.artUri?.toString() ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.music_note),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.music_note),
                        ),
                      ),
                    ),
                  ),
                
                // 歌曲信息
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentMediaItem != null)
                        Text(
                          currentMediaItem.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      if (currentMediaItem != null)
                        Text(
                          currentMediaItem.artist ?? 'Unknown Artist',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      // 进度条
                      if (playerState != null)
                        LinearProgressIndicator(
                          value: playerState.position.inMilliseconds.toDouble() / 
                              (playerState.duration?.inMilliseconds.toDouble() ?? 1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          backgroundColor: Colors.grey[300],
                        ),
                    ],
                  ),
                ),
                
                // 播放控制按钮
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        playerState?.playing == true 
                            ? Icons.pause 
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (playerState?.playing == true) {
                          AudioService.pause();
                        } else {
                          AudioService.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: AudioService.skipToNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
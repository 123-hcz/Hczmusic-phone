import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/audio_player_handler.dart';
import '../screens/player_screen.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final bool showPlayButton;

  const SongListItem({
    super.key,
    required this.song,
    this.onTap,
    this.showPlayButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final audioHandler = context.read<AudioPlayerHandler>();

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            imageUrl: song.albumCover,
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
      title: Text(
        song.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (song.isVip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(song.duration),
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 12,
            ),
          ),
          if (showPlayButton)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // 播放歌曲
                onTap?.call();
              },
            ) else
            IconButton(
              icon: const Icon(Icons.play_circle_filled_outlined),
              onPressed: () async {
                // 播放歌曲
                await audioHandler.playSong(song);
                
                // 跳转到播放器界面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayerScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      onTap: () async {
        // 如果没有指定onTap，直接播放歌曲
        if (onTap == null) {
          await audioHandler.playSong(song);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlayerScreen(),
            ),
          );
        } else {
          onTap?.call();
        }
      },
    );
  }

  String _formatDuration(Duration duration) {
    String minutes = (duration.inMinutes.remainder(60)).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds.remainder(60)).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
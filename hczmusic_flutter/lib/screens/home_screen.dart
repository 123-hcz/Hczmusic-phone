import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../widgets/song_list_item.dart';
import 'playlist_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> _songs = [];
  List<Song> _featuredPlaylists = [];
  bool _isLoading = true;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取每日推荐
      final dailyRecommendations = await _apiService.getDailyRecommendations();
      _songs = dailyRecommendations.take(8).toList();

      // 获取推荐歌单 - 暂时使用模拟数据，因为原API中没有直接获取推荐歌单的接口
      _featuredPlaylists = [
        Song(
          id: 'ranking',
          name: '排行榜',
          artist: '发现音乐',
          album: '排行榜',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: Duration.zero,
        ),
        Song(
          id: 'personal',
          name: '私人推荐',
          artist: '专属推荐',
          album: '推荐',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: Duration.zero,
        ),
        Song(
          id: 'classic',
          name: '经典金曲',
          artist: '怀旧金曲',
          album: '经典',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: Duration.zero,
        ),
      ];
    } catch (e) {
      print('加载首页数据失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '推荐',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildRecommendations(),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '每日推荐',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _isLoading
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _songs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            '暂无推荐歌曲',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return SongListItem(
                            song: _songs[index],
                            onTap: () {
                              // 播放歌曲
                            },
                          );
                        },
                        childCount: _songs.length,
                      ),
                    ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '推荐歌单',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildPlaylistCard(_featuredPlaylists[index]);
              },
              childCount: _featuredPlaylists.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // FM Radio Card
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '💖 MoeKoe Radio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.shuffle,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const Text(
                      '私人专属好歌推荐',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 125,
                          height: 125,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(62.5),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: const Icon(
                                Icons.graphic_eq,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Ranking Card
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                // 跳转到排行榜页面
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6a11cb), Color(0xFFFF9A9E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '排行榜',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '发现你的专属好歌',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(Song playlist) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          if (playlist.id == 'ranking') {
            // 跳转到排行榜页面 - 暂时使用模拟数据
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistDetailScreen(
                  playlistId: playlist.id,
                  playlistName: playlist.name,
                  playlistDescription: playlist.album,
                  playlistCover: playlist.albumCover,
                  songs: _songs,
                ),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  playlist.albumCover,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    playlist.artist,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
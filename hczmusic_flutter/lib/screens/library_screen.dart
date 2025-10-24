import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../widgets/song_list_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedCategory = 0;
  List<Song> _listenHistory = [];
  List<Song> _userPlaylists = [];
  List<Song> _collectedPlaylists = [];
  List<Song> _collectedAlbums = [];
  List<Song> _followedArtists = [];
  List<Song> _collectedFriends = [];
  bool _isLoading = true;
  late ApiService _apiService;

  final List<String> _categories = [
    '我创建的歌单',
    '我收藏的歌单',
    '我收藏的专辑',
    '我关注的歌手',
    '我关注的好友',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadLibraryData();
  }

  Future<void> _loadLibraryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟加载数据，因为原API可能需要登录才能获取用户数据
      // 这里我们先加载一些示例数据
      _listenHistory = [
        Song(
          id: 'h1',
          name: '最近播放歌曲1',
          artist: '歌手A',
          album: '专辑A',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: const Duration(minutes: 3, seconds: 30),
        ),
        Song(
          id: 'h2',
          name: '最近播放歌曲2',
          artist: '歌手B',
          album: '专辑B',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: const Duration(minutes: 4, seconds: 15),
        ),
        Song(
          id: 'h3',
          name: '最近播放歌曲3',
          artist: '歌手C',
          album: '专辑C',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: const Duration(minutes: 3, seconds: 45),
        ),
      ];

      _userPlaylists = [
        Song(
          id: 'up1',
          name: '我的歌单1',
          artist: '创建',
          album: '歌单',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: Duration.zero,
        ),
        Song(
          id: 'up2',
          name: '我的歌单2',
          artist: '创建',
          album: '歌单',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: Duration.zero,
        ),
      ];

      _collectedPlaylists = [
        Song(
          id: 'cp1',
          name: '收藏的歌单1',
          artist: '收藏',
          album: '歌单',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: Duration.zero,
        ),
        Song(
          id: 'cp2',
          name: '收藏的歌单2',
          artist: '收藏',
          album: '歌单',
          albumCover: 'https://via.placeholder.com/480x480',
          url: '',
          duration: Duration.zero,
        ),
      ];

    } catch (e) {
      print('加载我的音乐库数据失败: $e');
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
          SliverToBoxAdapter(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.primary,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage('https://via.placeholder.com/150x150'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '用户名称',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Lv.10',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'VIP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // 签到功能
                          },
                          icon: const Icon(Icons.event_available),
                          label: const Text('签到'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // 获取VIP功能
                          },
                          icon: const Icon(Icons.star),
                          label: const Text('VIP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // 签到
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text('签到'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 获取VIP
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('VIP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '我喜欢听',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return SongListItem(
                  song: _listenHistory[index],
                  onTap: () {
                    // 播放歌曲
                  },
                );
              },
              childCount: _listenHistory.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: _selectedCategory == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: _selectedCategory == index ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
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
              : _buildCategoryContent(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryContent() {
    List<Song> items = [];
    
    switch (_selectedCategory) {
      case 0:
        items = _userPlaylists;
        break;
      case 1:
        items = _collectedPlaylists;
        break;
      case 2:
        items = _collectedAlbums;
        break;
      case 3:
        items = _followedArtists;
        break;
      case 4:
        items = _collectedFriends;
        break;
    }

    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '暂无数据',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildPlaylistCard(items[index]);
        },
        childCount: items.length,
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
          // 跳转到歌单详情
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
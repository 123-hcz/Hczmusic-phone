import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../widgets/song_list_item.dart';
import 'playlist_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<Category> _categories = [];
  int _selectedMainCategory = 0;
  int _selectedSubCategory = 0;
  List<Song> _playlistList = [];
  bool _isLoading = true;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadDiscoverData();
  }

  Future<void> _loadDiscoverData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取歌单分类
      final categories = await _apiService.getPlaylistCategories();
      _categories = categories;
      
      if (_categories.isNotEmpty) {
        // 加载第一个分类下的歌单
        await _loadPlaylistsByCategory();
      }
    } catch (e) {
      print('加载发现页面数据失败: $e');
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '发现',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 主分类
                  if (_categories.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: FilterChip(
                              label: Text(_categories[index].name),
                              selected: _selectedMainCategory == index,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedMainCategory = index;
                                  _selectedSubCategory = 0;
                                });
                                _loadPlaylistsByCategory();
                              },
                              selectedColor: Theme.of(context).colorScheme.primary,
                              checkmarkColor: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  if (_categories.isNotEmpty && _categories[_selectedMainCategory].subCategories.isNotEmpty)
                    const SizedBox(height: 15),
                  // 子分类
                  if (_categories.isNotEmpty && _categories[_selectedMainCategory].subCategories.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories[_selectedMainCategory].subCategories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: FilterChip(
                              label: Text(_categories[_selectedMainCategory].subCategories[index].name),
                              selected: _selectedSubCategory == index,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSubCategory = index;
                                });
                                // 使用子分类ID获取歌单
                                final categoryId = _categories[_selectedMainCategory]
                                    .subCategories[index].id;
                                _loadPlaylistsByCategoryId(categoryId);
                              },
                              selectedColor: Theme.of(context).colorScheme.primary,
                              checkmarkColor: Colors.white,
                            ),
                          );
                        },
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
                '歌单推荐',
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
              : _playlistList.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            '暂无歌单',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildPlaylistCard(_playlistList[index]);
                    },
                    childCount: _playlistList.length,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailScreen(
                playlistId: playlist.id,
                playlistName: playlist.name,
                playlistDescription: playlist.album,
                playlistCover: playlist.albumCover,
                // 注意：这里需要获取具体的歌单详情，而不是直接传递当前歌单信息
                songs: [], // 歌单详情中会重新获取歌曲列表
              ),
            ),
          );
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

  Future<void> _loadPlaylistsByCategory() async {
    if (_categories.isEmpty) return;
    
    final categoryId = _categories[_selectedMainCategory].id;
    await _loadPlaylistsByCategoryId(categoryId);
  }

  Future<void> _loadPlaylistsByCategoryId(String categoryId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final playlists = await _apiService.getPlaylistsByCategory(categoryId);
      setState(() {
        _playlistList = playlists;
        _isLoading = false;
      });
    } catch (e) {
      print('加载分类歌单失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
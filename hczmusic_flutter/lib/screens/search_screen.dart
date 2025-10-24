import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../widgets/song_list_item.dart';
import 'playlist_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<SearchTab> _searchTabs = [
    SearchTab(type: 'song', name: '单曲'),
    SearchTab(type: 'special', name: '歌单'),
    SearchTab(type: 'album', name: '专辑'),
    SearchTab(type: 'author', name: '歌手'),
  ];
  int _selectedTab = 0;
  String _searchQuery = '';
  List<Song> _searchResults = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索歌曲、歌手、专辑...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
              },
              onSubmitted: (value) {
                _performSearch();
              },
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _searchTabs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: FilterChip(
                    label: Text(_searchTabs[index].name),
                    selected: _selectedTab == index,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTab = index;
                      });
                      if (_searchQuery.isNotEmpty) {
                        _performSearch();
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _searchResults.isEmpty
                    ? const Center(
                        child: Text(
                          '搜索您喜爱的音乐',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : _buildSearchResults(),
          ),
          if (_totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchTabs[_selectedTab].type == 'song') {
      return ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return SongListItem(
            song: _searchResults[index],
            onTap: () {
              // 播放歌曲
            },
          );
        },
      );
    } else {
      // 对于歌单、专辑、歌手，使用网格布局
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.8,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return _buildPlaylistCard(_searchResults[index]);
        },
      );
    }
  }

  Widget _buildPlaylistCard(Song playlist) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          // 跳转到歌单详情 - 如果是歌单类型
          if (_searchTabs[_selectedTab].type == 'special') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistDetailScreen(
                  playlistId: playlist.id,
                  playlistName: playlist.name,
                  playlistDescription: playlist.album,
                  playlistCover: playlist.albumCover,
                  songs: [], // 将在详情页中重新获取
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

  Widget _buildPagination() {
    List<Widget> pageButtons = [];

    // 上一页按钮
    pageButtons.add(
      TextButton(
        onPressed: _currentPage > 1 ? _prevPage : null,
        child: const Text('上一页'),
      ),
    );

    // 页码按钮
    int startPage = _currentPage > 3 ? _currentPage - 2 : 1;
    int endPage = startPage + 4 <= _totalPages ? startPage + 4 : _totalPages;

    if (startPage > 1) {
      pageButtons.add(
        TextButton(
          onPressed: () => _goToPage(1),
          child: const Text('1'),
        ),
      );
      if (startPage > 2) {
        pageButtons.add(const Text('...'));
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        TextButton(
          onPressed: () => _goToPage(i),
          style: i == _currentPage
              ? TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(i.toString()),
        ),
      );
    }

    if (endPage < _totalPages) {
      if (endPage < _totalPages - 1) {
        pageButtons.add(const Text('...'));
      }
      pageButtons.add(
        TextButton(
          onPressed: () => _goToPage(_totalPages),
          child: Text(_totalPages.toString()),
        ),
      );
    }

    // 下一页按钮
    pageButtons.add(
      TextButton(
        onPressed: _currentPage < _totalPages ? _nextPage : null,
        child: const Text('下一页'),
      ),
    );

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pageButtons,
      ),
    );
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.search(
        _searchQuery,
        type: _searchTabs[_selectedTab].type,
        page: _currentPage,
      );

      setState(() {
        _searchResults = _getResultsByType(result);
        _totalPages = (result.total / 30).ceil(); // 假设每页30条
        _isLoading = false;
      });
    } catch (e) {
      print('搜索失败: $e');
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  List<Song> _getResultsByType(SearchResult result) {
    switch (_searchTabs[_selectedTab].type) {
      case 'song':
        return result.songs;
      case 'special':
        return result.playlists;
      case 'album':
        return result.albums;
      case 'author':
        return result.artists;
      default:
        return [];
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _performSearch();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      _performSearch();
    }
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _performSearch();
  }
}

class SearchTab {
  final String type;
  final String name;

  SearchTab({required this.type, required this.name});
}
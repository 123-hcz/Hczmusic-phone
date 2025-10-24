import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../widgets/song_list_item.dart';
import '../theme/theme_manager.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final String? playlistName;
  final String? playlistDescription;
  final String? playlistCover;
  final List<Song>? songs;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    this.playlistName,
    this.playlistDescription,
    this.playlistCover,
    this.songs,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late List<Song> _songs;
  bool _isLoading = true;
  String _searchQuery = '';
  List<Song> _filteredSongs = [];
  int _sortField = 0; // 0: name, 1: artist, 2: album, 3: duration
  bool _sortAscending = true;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadPlaylistDetail();
  }

  Future<void> _loadPlaylistDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 如果传入了歌曲列表，直接使用；否则从API加载
      if (widget.songs != null && widget.songs!.isNotEmpty) {
        _songs = widget.songs!;
      } else {
        final detail = await _apiService.getPlaylistDetail(widget.playlistId);
        _songs = detail.tracks;
      }
      _filteredSongs = List.from(_songs);
    } catch (e) {
      print('加载歌单详情失败: $e');
      _songs = [];
      _filteredSongs = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchSongs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSongs = List.from(_songs);
      });
    } else {
      setState(() {
        _filteredSongs = _songs
            .where((song) =>
                song.name.toLowerCase().contains(query.toLowerCase()) ||
                song.artist.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _sortSongs() {
    setState(() {
      _filteredSongs.sort((a, b) {
        int result;
        switch (_sortField) {
          case 0: // name
            result = a.name.compareTo(b.name);
            break;
          case 1: // artist
            result = a.artist.compareTo(b.artist);
            break;
          case 2: // album
            result = a.album.compareTo(b.album);
            break;
          case 3: // duration
            result = a.duration.compareTo(b.duration);
            break;
          default:
            result = 0;
        }
        return _sortAscending ? result : -result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManager>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: themeProvider.isDarkTheme 
                ? Colors.grey[900] 
                : Colors.grey[100],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                ),
                child: ClipRRect(
                  child: widget.playlistCover != null
                      ? Image.network(
                          widget.playlistCover!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.white,
                        ),
                ),
              ),
              title: Text(
                widget.playlistName ?? '歌单详情',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.playlistDescription != null)
                    Text(
                      widget.playlistDescription!,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // 播放全部
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('播放'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          // 收藏歌单
                        },
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('收藏'),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // 更多操作
                          _showMoreOptions(context);
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索歌曲...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _searchSongs,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '歌曲列表 (${_filteredSongs.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.sort),
                    onSelected: (value) {
                      setState(() {
                        _sortField = value;
                        _sortAscending = !_sortAscending;
                        _sortSongs();
                      });
                    },
                    itemBuilder: (context) {
                      const fields = ['歌名', '歌手', '专辑', '时长'];
                      return fields.map((field) {
                        int index = fields.indexOf(field);
                        return PopupMenuItem(
                          value: index,
                          child: Row(
                            children: [
                              Text(field),
                              const SizedBox(width: 8),
                              Icon(
                                _sortField == index
                                    ? _sortAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward
                                    : Icons.arrow_upward,
                                size: 16,
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          ),
          _isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SongListItem(
                        song: _filteredSongs[index],
                        onTap: () {
                          // 播放歌曲
                        },
                        showPlayButton: true,
                      );
                    },
                    childCount: _filteredSongs.length,
                  ),
                ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('分享'),
                onTap: () {
                  Navigator.pop(context);
                  // 分享操作
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('添加到播放列表'),
                onTap: () {
                  Navigator.pop(context);
                  // 添加到播放列表
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除歌单'),
                onTap: () {
                  Navigator.pop(context);
                  // 删除歌单
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
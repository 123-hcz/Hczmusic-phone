import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../widgets/song_list_item.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistId;
  final String? artistName;
  final String? artistAvatar;

  const ArtistDetailScreen({
    super.key,
    required this.artistId,
    this.artistName,
    this.artistAvatar,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  ArtistDetail? _artistDetail;
  List<Song> _artistSongs = [];
  bool _isLoading = true;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadArtistDetail();
  }

  Future<void> _loadArtistDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 并行加载艺术家详情和歌曲
      final detailFuture = _apiService.getArtistDetail(widget.artistId);
      final songsFuture = _apiService.getArtistSongs(widget.artistId);
      
      _artistDetail = await detailFuture;
      _artistSongs = await songsFuture;
    } catch (e) {
      print('加载艺术家详情失败: $e');
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
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
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
                  child: _artistDetail?.avatar != null
                      ? Image.network(
                          _artistDetail!.avatar,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : widget.artistAvatar != null
                          ? Image.network(
                              widget.artistAvatar!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : const Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.white,
                            ),
                ),
              ),
              title: Text(
                _artistDetail?.name ?? widget.artistName ?? '歌手详情',
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
                  if (_artistDetail != null)
                    Text(
                      _artistDetail!.intro,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () {
                          // 关注艺术家
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('关注'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          // 分享艺术家
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('分享'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_artistDetail != null)
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(_artistDetail!.songCount.toString(), '歌曲'),
                      _buildStatItem(_artistDetail!.albumCount.toString(), '专辑'),
                      _buildStatItem(_artistDetail!.mvCount.toString(), 'MV'),
                      _buildStatItem(_artistDetail!.fansCount.toString(), '粉丝'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '热门歌曲',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
              : _artistSongs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '暂无歌曲',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SongListItem(
                        song: _artistSongs[index],
                        onTap: () {
                          // 播放歌曲
                        },
                        showPlayButton: true,
                      );
                    },
                    childCount: _artistSongs.length,
                  ),
                ),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
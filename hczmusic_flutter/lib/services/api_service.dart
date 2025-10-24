import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/song.dart';

class ApiService {
  static const String _baseUrl = 'https://hmusicapi.胡.fun'; // 使用hmusicapi.胡.fun API地址
  final Dio _dio = Dio();

  // 初始化Dio配置
  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  // 每日推荐
  Future<List<Song>> getDailyRecommendations() async {
    try {
      final response = await _dio.get('/everyday/recommend');
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final List<dynamic> songList = response.data['data']['song_list'];
        return songList.map((songData) => _parseRecommendationSong(songData)).toList();
      }
      return [];
    } catch (e) {
      print('获取每日推荐失败: $e');
      return [];
    }
  }

  // 搜索
  Future<SearchResult> search(String keywords, {String type = 'song', int page = 1, int pageSize = 30}) async {
    try {
      final response = await _dio.get('/search', queryParameters: {
        'keywords': keywords,
        'page': page,
        'pagesize': pageSize,
        'type': type,
      });
      
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final data = response.data['data'];
        final List<dynamic> lists = data['lists'];
        
        List<Song> songs = [];
        List<Song> playlists = [];
        List<Song> albums = [];
        List<Song> artists = [];
        
        if (type == 'song') {
          songs = lists.map((item) => _parseSearchSong(item)).toList();
        } else if (type == 'special') {
          playlists = lists.map((item) => _parseSearchPlaylist(item)).toList();
        } else if (type == 'album') {
          albums = lists.map((item) => _parseSearchAlbum(item)).toList();
        } else if (type == 'author') {
          artists = lists.map((item) => _parseSearchArtist(item)).toList();
        }
        
        return SearchResult(
          songs: songs,
          playlists: playlists,
          albums: albums,
          artists: artists,
          total: data['total'] ?? 0,
          hasMore: data['hasMore'] ?? false,
        );
      }
      return SearchResult(
        songs: [],
        playlists: [],
        albums: [],
        artists: [],
        total: 0,
        hasMore: false,
      );
    } catch (e) {
      print('搜索失败: $e');
      return SearchResult(
        songs: [],
        playlists: [],
        albums: [],
        artists: [],
        total: 0,
        hasMore: false,
      );
    }
  }

  // 获取歌单详情
  Future<PlaylistDetail> getPlaylistDetail(String globalCollectionId) async {
    try {
      final response = await _dio.get('/playlist/detail', queryParameters: {
        'ids': globalCollectionId,
      });
      
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final playlistData = response.data['data'][0];
        final playlist = _parsePlaylist(playlistData);
        
        // 获取歌单歌曲
        final tracks = await getPlaylistTracks(globalCollectionId);
        
        return PlaylistDetail(
          playlist: playlist,
          tracks: tracks,
        );
      }
      throw Exception('获取歌单详情失败');
    } catch (e) {
      print('获取歌单详情失败: $e');
      throw Exception('获取歌单详情失败: $e');
    }
  }

  // 获取歌单歌曲
  Future<List<Song>> getPlaylistTracks(String globalCollectionId) async {
    try {
      int page = 1;
      const pageSize = 250;
      List<Song> allTracks = [];
      
      // 获取第一页
      final firstPageResponse = await _dio.get('/playlist/track/all', queryParameters: {
        'id': globalCollectionId,
        'page': page,
        'pagesize': pageSize,
      });
      
      if (firstPageResponse.statusCode == 200 && firstPageResponse.data['status'] == 1) {
        final infoList = firstPageResponse.data['data']['info'];
        final formattedTracks = infoList.map((track) {
          final nameParts = track['name'].split(' - ');
          return Song(
            id: track['hash'] ?? '',
            name: nameParts.length > 1 ? nameParts[1] : track['name'],
            artist: nameParts.length > 1 ? nameParts[0] : 'Unknown Artist',
            album: track['albuminfo']?['name'] ?? '',
            albumCover: (track['cover'] ?? '')
                .replaceAll('{size}', '480')
                .replaceAll('http://', 'https://'),
            url: '', // 播放URL需要单独获取
            duration: Duration(seconds: track['timelen'] ?? 0),
            isVip: (track['privilege'] ?? 0) == 10,
            hash: track['hash'] ?? '',
          );
        }).toList();
        
        allTracks.addAll(formattedTracks);
        page++;
      }
      
      // 计算总页数并获取剩余页面
      final count = firstPageResponse.data['data']['info'].length;
      final totalPages = (count / pageSize).ceil();
      
      for (int i = 1; i < totalPages; i++) {
        try {
          final response = await _dio.get('/playlist/track/all', queryParameters: {
            'id': globalCollectionId,
            'page': page,
            'pagesize': pageSize,
          });
          
          if (response.statusCode == 200 && response.data['status'] == 1) {
            final infoList = response.data['data']['info'];
            if (infoList.length > 0) {
              final formattedTracks = infoList.map((track) {
                final nameParts = track['name'].split(' - ');
                return Song(
                  id: track['hash'] ?? '',
                  name: nameParts.length > 1 ? nameParts[1] : track['name'],
                  artist: nameParts.length > 1 ? nameParts[0] : 'Unknown Artist',
                  album: track['albuminfo']?['name'] ?? '',
                  albumCover: (track['cover'] ?? '')
                      .replaceAll('{size}', '480')
                      .replaceAll('http://', 'https://'),
                  url: '', // 播放URL需要单独获取
                  duration: Duration(seconds: track['timelen'] ?? 0),
                  isVip: (track['privilege'] ?? 0) == 10,
                  hash: track['hash'] ?? '',
                );
              }).toList();
              
              allTracks.addAll(formattedTracks);
              page++;
            }
            if (infoList.length < pageSize) break;
          } else {
            break;
          }
        } catch (e) {
          print('获取更多歌单歌曲失败: $e');
          break;
        }
      }
      
      return allTracks;
    } catch (e) {
      print('获取歌单歌曲失败: $e');
      return [];
    }
  }

  // 获取歌手详情
  Future<ArtistDetail> getArtistDetail(String artistId) async {
    try {
      final response = await _dio.get('/artist/detail', queryParameters: {
        'id': artistId,
      });
      
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final artistData = response.data['data'];
        return ArtistDetail(
          id: artistId,
          name: artistData['author_name'] ?? '',
          avatar: artistData['sizable_avatar']?.replaceAll('{size}', '480') ?? '',
          songCount: artistData['song_count'] ?? 0,
          albumCount: artistData['album_count'] ?? 0,
          mvCount: artistData['mv_count'] ?? 0,
          fansCount: artistData['fansnums'] ?? 0,
          intro: artistData['intro'] ?? '',
          longIntro: artistData['long_intro'] ?? [],
        );
      }
      throw Exception('获取歌手详情失败');
    } catch (e) {
      print('获取歌手详情失败: $e');
      throw Exception('获取歌手详情失败: $e');
    }
  }

  // 获取歌手歌曲
  Future<List<Song>> getArtistSongs(String artistId, {String sort = 'hot', int page = 1, int pageSize = 250}) async {
    try {
      int currentPage = 1;
      List<Song> allTracks = [];
      
      // 获取第一页
      final firstPageResponse = await _dio.get('/artist/audios', queryParameters: {
        'id': artistId,
        'sort': sort,
        'page': currentPage,
        'pagesize': pageSize,
      });
      
      if (firstPageResponse.statusCode == 200 && firstPageResponse.data['status'] == 1) {
        final songList = firstPageResponse.data['data'];
        final formattedTracks = songList.map((track) => Song(
          id: track['hash'] ?? '',
          name: track['audio_name'] ?? '',
          artist: track['author_name'] ?? 'Unknown Artist',
          album: track['album_name'] ?? '',
          albumCover: track['trans_param']?['union_cover']
                  ?.replaceAll('{size}', '480')
                  .replaceAll('http://', 'https://') ?? '',
          url: '', // 播放URL需要单独获取
          duration: Duration(seconds: track['timelength'] ?? 0),
          isVip: (track['privilege'] ?? 0) == 10,
          hash: track['hash'] ?? '',
        )).toList();
        
        allTracks.addAll(formattedTracks);
        currentPage++;
      }
      
      // 根据歌手详情中的歌曲总数计算总页数
      // 这里我们模拟获取更多页面，实际应根据返回数据判断
      for (int i = 1; i < 3; i++) { // 假设最多3页
        try {
          final response = await _dio.get('/artist/audios', queryParameters: {
            'id': artistId,
            'sort': sort,
            'page': currentPage,
            'pagesize': pageSize,
          });
          
          if (response.statusCode == 200 && response.data['status'] == 1) {
            final songList = response.data['data'];
            if (songList.length > 0) {
              final formattedTracks = songList.map((track) => Song(
                id: track['hash'] ?? '',
                name: track['audio_name'] ?? '',
                artist: track['author_name'] ?? 'Unknown Artist',
                album: track['album_name'] ?? '',
                albumCover: track['trans_param']?['union_cover']
                        ?.replaceAll('{size}', '480')
                        .replaceAll('http://', 'https://') ?? '',
                url: '', // 播放URL需要单独获取
                duration: Duration(seconds: track['timelength'] ?? 0),
                isVip: (track['privilege'] ?? 0) == 10,
                hash: track['hash'] ?? '',
              )).toList();
              
              allTracks.addAll(formattedTracks);
              currentPage++;
            }
            if (songList.length < pageSize) break;
          } else {
            break;
          }
        } catch (e) {
          print('获取更多歌手歌曲失败: $e');
          break;
        }
      }
      
      return allTracks;
    } catch (e) {
      print('获取歌手歌曲失败: $e');
      return [];
    }
  }

  // 获取歌单分类
  Future<List<Category>> getPlaylistCategories() async {
    try {
      final response = await _dio.get('/playlist/tags');
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final List<dynamic> categoriesData = response.data['data'];
        return categoriesData.map((catData) => Category(
          id: catData['tag_id'].toString(),
          name: catData['tag_name'],
          subCategories: (catData['son'] as List<dynamic>?)
              ?.map((subData) => SubCategory(
                    id: subData['tag_id'].toString(),
                    name: subData['tag_name'],
                  ))
              .toList() ?? [],
        )).toList();
      }
      return [];
    } catch (e) {
      print('获取歌单分类失败: $e');
      return [];
    }
  }

  // 根据分类获取歌单
  Future<List<Song>> getPlaylistsByCategory(String categoryId, {int page = 1}) async {
    try {
      final response = await _dio.get('/top/playlist', queryParameters: {
        'withsong': 0,
        'category_id': categoryId,
      });
      
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final List<dynamic> playlistsData = response.data['data']['special_list'];
        return playlistsData.map((playlistData) => Song(
          id: playlistData['global_collection_id'] ?? '',
          name: playlistData['specialname'] ?? 'Unknown Playlist',
          artist: '歌单',
          album: playlistData['intro'] ?? '',
          albumCover: playlistData['flexible_cover']
              ?.replaceAll('{size}', '240')
              .replaceAll('http://', 'https://') ?? '',
          url: '',
          duration: Duration.zero,
        )).toList();
      }
      return [];
    } catch (e) {
      print('根据分类获取歌单失败: $e');
      return [];
    }
  }

  // 获取歌曲播放URL
  Future<String> getSongUrl(String hash) async {
    try {
      // 需要从搜索结果获取文件ID，然后获取播放URL
      final searchResponse = await _dio.get('/search', queryParameters: {
        'keywords': hash,
        'page': 1,
        'pagesize': 1,
        'type': 'song',
      });

      if (searchResponse.statusCode == 200 && searchResponse.data['status'] == 1) {
        final List<dynamic> lists = searchResponse.data['data']['lists'];
        if (lists.isNotEmpty) {
          final song = lists[0];
          final fileHash = song['FileHash'] ?? hash;
          final albumId = song['AlbumID'] ?? '0';
          
          // 尝试获取播放URL
          final urlResponse = await _dio.get('/download', queryParameters: {
            'hash': fileHash,
            'album_id': albumId,
          });
          
          if (urlResponse.statusCode == 200 && urlResponse.data['status'] == 1) {
            return urlResponse.data['data']['url'] ?? '';
          }
        }
      }
      return '';
    } catch (e) {
      print('获取歌曲播放URL失败: $e');
      return '';
    }
  }

  // 解析每日推荐歌曲
  Song _parseRecommendationSong(dynamic songData) {
    return Song(
      id: songData['hash'] ?? '',
      name: songData['ori_audio_name'] ?? 'Unknown Song',
      artist: songData['author_name'] ?? 'Unknown Artist',
      album: '推荐',
      albumCover: songData['sizable_cover']
          ?.replaceAll('{size}', '480')
          .replaceAll('http://', 'https://') ?? '',
      url: '',
      duration: Duration(seconds: songData['time_length'] ?? 0),
    );
  }

  // 解析搜索歌曲结果
  Song _parseSearchSong(dynamic item) {
    return Song(
      id: item['FileHash'] ?? '',
      name: item['SongName']?.split(' - ')[1] ?? item['SongName'] ?? 'Unknown Song',
      artist: item['SingerName'] ?? 'Unknown Artist',
      album: item['AlbumName'] ?? 'Unknown Album',
      albumCover: item['Image']?.replaceAll('{size}', '480') ?? '',
      url: '',
      duration: Duration(milliseconds: item['Duration'] ?? 0),
    );
  }

  // 解析搜索歌单结果
  Song _parseSearchPlaylist(dynamic item) {
    return Song(
      id: item['global_collection_id'] ?? '',
      name: item['specialname'] ?? 'Unknown Playlist',
      artist: item['intro']?.substring(0, 30) + '...' ?? '歌单',
      album: '歌单',
      albumCover: item['pic'] ?? '',
      url: '',
      duration: Duration.zero,
    );
  }

  // 解析搜索专辑结果
  Song _parseSearchAlbum(dynamic item) {
    return Song(
      id: item['albumid'] ?? '',
      name: item['albumname'] ?? 'Unknown Album',
      artist: item['singername'] ?? 'Unknown Artist',
      album: '专辑',
      albumCover: item['imgurl'] ?? '',
      url: '',
      duration: Duration.zero,
    );
  }

  // 解析搜索歌手结果
  Song _parseSearchArtist(dynamic item) {
    return Song(
      id: item['AuthorID'] ?? '',
      name: item['AuthorName'] ?? 'Unknown Artist',
      artist: '歌手',
      album: '艺人',
      albumCover: item['avatar'] ?? '',
      url: '',
      duration: Duration.zero,
    );
  }

  // 解析歌单数据
  Song _parsePlaylist(dynamic playlistData) {
    return Song(
      id: playlistData['global_collection_id'] ?? '',
      name: playlistData['name'] ?? 'Unknown Playlist',
      artist: playlistData['list_create_username'] ?? 'Unknown User',
      album: playlistData['intro'] ?? '',
      albumCover: playlistData['pic'] ?? '',
      url: '',
      duration: Duration.zero,
    );
  }

  // 用户登录
  Future<UserLoginResult> login(String username, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final userData = response.data['data'];
        return UserLoginResult(
          success: true,
          token: userData['token'] ?? '',
          userId: userData['userid'] ?? '',
          userInfo: UserInfo(
            userId: userData['userid'] ?? '',
            nickname: userData['nickname'] ?? '',
            avatar: userData['avatar'] ?? '',
            token: userData['token'] ?? '',
          ),
          message: '登录成功',
        );
      } else {
        return UserLoginResult(
          success: false,
          message: response.data['msg'] ?? '登录失败',
        );
      }
    } catch (e) {
      print('登录失败: $e');
      return UserLoginResult(
        success: false,
        message: '网络错误，请检查网络连接',
      );
    }
  }

  // 用户登录 - 通过手机号
  Future<UserLoginResult> loginByPhone(String phone, String password) async {
    try {
      final response = await _dio.post('/login/cellphone', data: {
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final userData = response.data['data'];
        return UserLoginResult(
          success: true,
          token: userData['token'] ?? '',
          userId: userData['userid'] ?? '',
          userInfo: UserInfo(
            userId: userData['userid'] ?? '',
            nickname: userData['nickname'] ?? '',
            avatar: userData['avatar'] ?? '',
            token: userData['token'] ?? '',
          ),
          message: '登录成功',
        );
      } else {
        return UserLoginResult(
          success: false,
          message: response.data['msg'] ?? '登录失败',
        );
      }
    } catch (e) {
      print('手机登录失败: $e');
      return UserLoginResult(
        success: false,
        message: '网络错误，请检查网络连接',
      );
    }
  }

  // 获取用户信息
  Future<UserInfo?> getUserInfo(String token, String userId) async {
    try {
      // 在URL中添加token和userid参数
      final response = await _dio.get('/user/detail', queryParameters: {
        'token': token,
        'userid': userId,
      });

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final userData = response.data['data'];
        return UserInfo(
          userId: userId,
          nickname: userData['nickname'] ?? '',
          avatar: userData['avatar'] ?? '',
          token: token,
          gender: userData['gender'] ?? 0,
          birthday: userData['birthday'] ?? 0,
          signature: userData['signature'] ?? '',
          listenSongs: userData['listenSongs'] ?? 0,
        );
      }
      return null;
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }
}

class UserLoginResult {
  final bool success;
  final String? token;
  final String? userId;
  final UserInfo? userInfo;
  final String message;

  UserLoginResult({
    required this.success,
    this.token,
    this.userId,
    this.userInfo,
    required this.message,
  });
}

class UserInfo {
  final String userId;
  final String nickname;
  final String avatar;
  final String token;
  final int gender;
  final int birthday;
  final String signature;
  final int listenSongs;

  UserInfo({
    required this.userId,
    required this.nickname,
    required this.avatar,
    required this.token,
    this.gender = 0,
    this.birthday = 0,
    this.signature = '',
    this.listenSongs = 0,
  });
}

class SearchResult {
  final List<Song> songs;
  final List<Song> playlists;
  final List<Song> albums;
  final List<Song> artists;
  final int total;
  final bool hasMore;

  SearchResult({
    required this.songs,
    required this.playlists,
    required this.albums,
    required this.artists,
    required this.total,
    required this.hasMore,
  });
}

class PlaylistDetail {
  final Song playlist;
  final List<Song> tracks;

  PlaylistDetail({
    required this.playlist,
    required this.tracks,
  });
}

class ArtistDetail {
  final String id;
  final String name;
  final String avatar;
  final int songCount;
  final int albumCount;
  final int mvCount;
  final int fansCount;
  final String intro;
  final List<dynamic> longIntro;

  ArtistDetail({
    required this.id,
    required this.name,
    required this.avatar,
    required this.songCount,
    required this.albumCount,
    required this.mvCount,
    required this.fansCount,
    required this.intro,
    required this.longIntro,
  });
}

class Category {
  final String id;
  final String name;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.subCategories,
  });
}

class SubCategory {
  final String id;
  final String name;

  SubCategory({
    required this.id,
    required this.name,
  });
}
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class UserState extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _username;
  String? _avatar;
  bool _isAuthenticated = false;
  List<Song> _likeList = [];

  String? get token => _token;
  String? get userId => _userId;
  String? get username => _username;
  String? get avatar => _avatar;
  bool get isAuthenticated => _isAuthenticated;
  List<Song> get likeList => _likeList;

  UserState() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _username = prefs.getString('username');
    _avatar = prefs.getString('avatar');
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    
    notifyListeners();
  }

  Future<void> login(String token, String userId, String username, String avatar) async {
    _token = token;
    _userId = userId;
    _username = username;
    _avatar = avatar;
    _isAuthenticated = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('avatar', avatar);
    await prefs.setBool('isAuthenticated', true);

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _username = null;
    _avatar = null;
    _isAuthenticated = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('avatar');
    await prefs.setBool('isAuthenticated', false);

    notifyListeners();
  }

  Future<void> updateUserInfo({String? username, String? avatar}) async {
    if (username != null) _username = username;
    if (avatar != null) _avatar = avatar;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (username != null) await prefs.setString('username', username);
    if (avatar != null) await prefs.setString('avatar', avatar);

    notifyListeners();
  }

  void addToLikeList(Song song) {
    if (!_likeList.any((element) => element.id == song.id)) {
      _likeList.add(song);
      notifyListeners();
    }
  }

  void removeFromLikeList(String songId) {
    _likeList.removeWhere((element) => element.id == songId);
    notifyListeners();
  }

  bool isSongLiked(String songId) {
    return _likeList.any((element) => element.id == songId);
  }
}
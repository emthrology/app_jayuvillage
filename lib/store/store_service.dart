import 'package:shared_preferences/shared_preferences.dart';

class StoreService {
  Future<String?> getPrefs(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setPrefs(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  final Map<String, CacheEntry> _cache = {};

  List<dynamic>? getCachedData(String key) {
    final entry = _cache[key];
    if (entry != null) {
      if (entry.isValid()) {
        return entry.data;
      } else {
        _cache.remove(key); // 유효성 검사 실패 시 캐시에서 제거
      }
    }
    return null;
  }

  void setCachedData(String key, List<dynamic> data) {
    _cache[key] = CacheEntry(data);
  }

  void removeCache(String key) {
    _cache.remove(key);
  }

  void clearCache() {
    // print('claerCache called');
    _cache.clear();
  }
}

class CacheEntry {
  final List<dynamic> data;
  final DateTime timestamp;

  CacheEntry(this.data) : timestamp = DateTime.now();

  bool isValid() {
    // 10분 동안 유효한 캐시로 설정
    return DateTime.now().difference(timestamp).inMinutes < 10;
  }
}
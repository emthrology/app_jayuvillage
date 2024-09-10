// playlist_repository.dart
abstract class PlaylistRepository {
  Future<List<Map<String, dynamic>>> fetchInitialPlaylist();
  Future<Map<String, dynamic>> fetchAnotherSong();
  void updateMusicItems(List<Map<String, dynamic>> items);
}

class Playlist extends PlaylistRepository {
  List<Map<String, dynamic>> _playlistItems = [];

  @override
  void updateMusicItems(List<Map<String, dynamic>> items) {
    _playlistItems = items;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchInitialPlaylist({int length = 3}) async {
    if (_playlistItems.isEmpty) {
      return [];
    }
    final itemCount = length < _playlistItems.length ? length : _playlistItems.length;
    return List.generate(itemCount, (index) => _convertToPlaylistItem(_playlistItems[index]));
  }

  @override
  Future<Map<String, dynamic>> fetchAnotherSong() async {
    if (_playlistItems.isEmpty) {
      throw Exception('No more songs available');
    }
    return _convertToPlaylistItem(_playlistItems[_songIndex++ % _playlistItems.length]);
  }

  int _songIndex = 0;

  Map<String, dynamic> _convertToPlaylistItem(Map<String, dynamic> item) {
    return {
      'id': item['id'].toString(),
      'title': item['title'] ?? 'Unknown Title',
      'album': item['album'] ?? 'Unknown Album',
      'url': item['audioUrl'] ?? '',
      'artUri': item['imageUrl'] ?? 'asset/images/default_thumbnail.png',
    };
  }
}
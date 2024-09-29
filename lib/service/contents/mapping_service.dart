
import '../../const/contents/content_type.dart';

class MappingService {
  List<Map<String, dynamic>> mapItems(
      List<dynamic> apiData, ContentType type) {
    return apiData
        .map((item) => {
      'type': type,
      'id': item['id'] ?? 0,
      'opening': item['opening'] ?? 0,
      'imageUrl': item['audio_thumbnail'] ?? 'asset/images/upset.png',
      'title': item['title'] ?? '',
      'subtitle': item['content'] ?? '',
      'listerCount': item['view_count'] ?? '',
      'viewCount': item['view_count'] ?? 0,
      'shareCount': item['share_count'] ?? 0,
      'likeCount': item['like_count'] ?? 0,
      'isLike': item['is_like'] == 1,
      'audioUrl': item['audio_url'] ?? '',
      'file': item['file'] ?? '',
      'isLive': item['live_status'] == 1 ? true : false,
      'startTime': item['startTime'] ?? '14:00',
      'endTime': item['endTime'] ?? '',
      'album': item['album'] ?? '',
      'author': item['author'] ?? '',
      'createdAt': item['created_at'] ?? '',
      'diffAt': item['diff_at'] ?? '',
    })
        .toList();
  }
  T? getEnumFromString<T extends Enum>(String str, List<T> values) {
    try {
      return values.firstWhere((e) => e.name.toLowerCase() == str.toLowerCase());
    } on StateError {
      return null; // 일치하는 enum 값이 없을 경우
    }
  }
  String? getStringFromEnum<T extends Enum>(T enumValue) {
    return enumValue.name;
  }
  List<Map<String, dynamic>> mapItemsFromStoreList(List<dynamic> apiData) {
    return apiData.map((item) => {
      'type': getEnumFromString(item['category'], ContentType.values),
      'id': item['id'] ?? 0,
      'opening': item['openinig'] ?? 0,
      'imageUrl': item['audio_thumbnail'] ?? 'asset/images/upset.png',
      'title': item['title'] ?? '',
      'subtitle': item['content'] ?? '',
      'listerCount': item['view_count'] ?? '',
      'viewCount': item['view_count'] ?? 0,
      'shareCount': item['share_count'] ?? 0,
      'likeCount': item['like_count'] ?? 0,
      'isLike': item['is_like'] == 1,
      'audioUrl': item['audio_url'] ?? '',
      'file': item['file'] ?? '',

      'isLive': item['live_status'] == 1 ? true : false,
      'startTime' : item['startTime'] ?? '14:00',
      'endTime' : item['endTime'] ?? '',

      'album': item['title'] ?? '',

      'createdAt': item['created_at'] ?? '',
      'diffAt': item['diff_at'] ?? '',
    }).toList();
  }
}

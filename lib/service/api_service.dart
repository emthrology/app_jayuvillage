import 'package:dio/dio.dart';
import 'package:webview_ex/const/env.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = BASE_URL;

  Future<List<Map<String, dynamic>>> fetchItems({required String endpoint, required String query, required String value}) async {
    try {
      final response = await _dio.get('$baseUrl/$endpoint?$query=$value');
      if(response.statusCode == 200) {
        // print('${response.data['data']}');
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('$endpoint $value 불러오기 실패');
      }
    }catch (e) {
      throw Exception('$endpoint $value 불러오기 중 오류 발생: $e');
    }
  }
}
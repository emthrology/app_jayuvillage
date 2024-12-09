import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_ex/const/env.dart';
import 'package:webview_ex/store/store_service.dart';

import 'dependency_injecter.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = BASE_URL;

  // final StoreService _storeService = StoreService();
  final _storeService = getIt<StoreService>();
  Future<String?> getCsrfToken() async {
    String? token = await _storeService.getPrefs('XSRF_TOKEN');
    return token;
  }
  Future<List<dynamic>> fetchItems({required String endpoint, Map<String, String>? queries, bool useCache = true,  bool useWhole = false}) async {
    // 쿼리 파라미터를 URL에 추가
    String queryString = '';
    List<dynamic>? cachedData;
    String cacheKey = '';
    if (queries != null && queries.isNotEmpty) {
      queryString =  queries.entries.map((e) => '${e.key}=${e.value}').join('&');
    }
    final uri = Uri.parse('$baseUrl/$endpoint?$queryString');
    print('$baseUrl/$endpoint?$queryString');
    if(useCache) {
      // 캐시 키 생성
      cacheKey = queryString.isNotEmpty ? '$endpoint?$queryString' : endpoint;
      // 캐시된 데이터 확인 및 유효성 검사
      cachedData = _storeService.getCachedData(cacheKey);
    }
    if (cachedData != null) {
      return cachedData;
    }else {
      try {
        String? token = await getCsrfToken();
        final response = await _dio.get(
            uri.toString(),
            options: Options(
                headers: {
                  "Authorization": "Bearer $token"
                }
            )
        );
        if(response.statusCode == 200 && response.data is! String) {
          final responseData = useWhole ? response.data :response.data['data'];
          if (responseData is List) {
            final data = List<dynamic>.from(responseData);
            if(useCache)_storeService.setCachedData(cacheKey, data);
            return data;
          } else if (responseData is Map<String, dynamic>) {
            // 단일 객체인 경우 리스트로 변환
            final data = [responseData];
            if(useCache)_storeService.setCachedData(cacheKey, data);
            return data;
          } else {
            // 예상치 못한 데이터 형식인 경우
            throw Exception('Unexpected data format: ${response.data}');
          }
        }else {
          Fluttertoast.showToast(
              msg: "불러오기 실패하였습니다.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Color(0xffff0000),
              textColor: Colors.white,
              fontSize: 16.0
          );
          throw Exception('$endpoint 불러오기 실패');
        }
      }on DioException catch (e) {
        debugPrint('resposne:${e.response}');
        if (e.response != null) {
          debugPrint('Status code: ${e.response?.statusCode}');
          debugPrint('Data: ${e.response?.data}');
          debugPrint('Headers: ${e.response?.headers}');
        } else {
          debugPrint('Error message: ${e.message}');
        }
        print(e);
        Fluttertoast.showToast(
            msg: "$endpoint 불러오기 중 오류 발생",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xffff0000),
            textColor: Colors.white,
            fontSize: 16.0
        );
        throw Exception('$baseUrl/$endpoint?$queryString: $endpoint 불러오기 중 오류 발생: $e');
      }
    }

  }

  Future<void> postItem({required String endpoint, required String completeWord, Map<String,dynamic>? body }) async {
    try {
      String? token = await getCsrfToken();
      final response = await _dio.post(
        '$baseUrl/$endpoint',
        data: body,
        options: Options(
            headers: {
              "Authorization": "Bearer $token"
            },
        )
      );
      if((response.statusCode == 200 || response.statusCode == 201) && response.data is! String) {
        _storeService.clearCache();
        Fluttertoast.showToast(
            msg: "$completeWord 완료되었습니다.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xff0baf00),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else {
        Fluttertoast.showToast(
            msg: "$completeWord 실패하였습니다.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xffff0000),
            textColor: Colors.white,
            fontSize: 16.0
        );
        throw Exception('$endpoint 등록 실패');
      }
    } catch(e) {
      Fluttertoast.showToast(
          msg: "$completeWord 실패하였습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Color(0xffff0000),
          textColor: Colors.white,
          fontSize: 16.0
      );
      throw Exception('$endpoint $completeWord 중 오류 발생: $e');
    }
  }

  Future<Response> postItemWithResponse({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      String? token = await getCsrfToken();
      final response = await _dio.post(
        '$baseUrl/$endpoint',
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $token"
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Error during POST request: $e');
    }
  }
  Future<Response> putItemWithResponse({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      print('$baseUrl/$endpoint',);
      String? token = await getCsrfToken();
      final response = await _dio.put(
        '$baseUrl/$endpoint',
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $token"
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Error during POST request: $e');
    }
  }

  Future<void> deleteItem({required String endpoint, required String id}) async {
    try {
      String? token = await getCsrfToken();
      final response = await _dio.delete(
          '$baseUrl/$endpoint/$id',
          options: Options(
              headers: {
                "Authorization": "Bearer $token"
              }
          )
      );
      if(response.statusCode == 200 && response.data is! String) {
        _storeService.clearCache();
        Fluttertoast.showToast(
            msg: "삭제가 완료되었습니다.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xff0baf00),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else {
        Fluttertoast.showToast(
            msg: "삭제 실패하였습니다.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xffff0000),
            textColor: Colors.white,
            fontSize: 16.0
        );
        throw Exception('$endpoint 삭제 실패');
      }
    } catch(e) {
      Fluttertoast.showToast(
          msg: "삭제 중 오류가 발생하였습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Color(0xffff0000),
          textColor: Colors.white,
          fontSize: 16.0
      );
      throw Exception('$endpoint 삭제 중 오류 발생: $e');
    }
  }

  Future<void> storeToken(token, userId) async {
    final response = await _dio.post('$baseUrl/store-token',
        data: {
          'token': token,
          'user_id': userId
        },

        options: Options(
            validateStatus: (statusCode) {
              if (statusCode == null) {
                return false;
              } else {
                return statusCode >= 200 && statusCode <= 500;
              }
            }
        )
    );
  }
}
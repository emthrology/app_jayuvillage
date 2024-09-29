import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_ex/const/contents/content_type.dart';
import 'package:webview_ex/service/api_service.dart';
import 'package:webview_ex/service/player_manager.dart';

import '../service/contents/mapping_service.dart';
import '../service/dependency_injecter.dart';
import '../store/secure_storage.dart';
import '../store/store_service.dart';

class CommentsSection extends StatefulWidget {
  final ContentType contentType;
  final String commentableId;
  const CommentsSection({super.key, required this.contentType, required this.commentableId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final ApiService _apiService = ApiService();
  final MappingService _mappingService = MappingService();
  final playerManager = getIt<PlayerManager>();
  final _storeService = getIt<StoreService>();
  final secureStorage = getIt<SecureStorage>();
  String userId = '';
  late String sessionData;
  final TextEditingController _commentController = TextEditingController();
  final String endpoint = 'comments';
  List<Map<String,dynamic>> comments = []; // 댓글 리스트
  Future<void> getComments() async {
    try {
      Map<String, String> queryParams = {
        // 'commentable_type': _mappingService.getStringFromEnum(widget.contentType),
        'commentable_type': 'audio',
        'commentable_id': widget.commentableId,
      };
      final commentsListData = await _apiService.fetchItems(endpoint: endpoint, queries: queryParams);
      setState(() {
        //TODO 다받아서 가공하기
        comments = commentsListData.map((item) => {
          'id': item['id'].toString(),
          'user_id': item['user']['id'],
          'nickname': item['user']['nickname'].toString(),
          'district': item['user']['district'],
          'diff_at' : item['diff_at'],
          'content': item['content'] as String
        }).toList();
        String queryString =  queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');;
        String cacheKey = '$endpoint?$queryString';
        _storeService.removeCache(cacheKey);
      });
    } catch(e) {
      print(e);
    }
  }
  void _addComment() async {
    final text = _commentController.text;
    print('commentText:$text');
    if(text.isNotEmpty) {
      final Map<String, dynamic> body = {
        // 'commentable_type': _mappingService.getStringFromEnum(widget.contentType),
        'commentable_type': 'audio',
        'commentable_id': widget.commentableId,
        'content':text,
      };
      try {
        Response res = await _apiService.postItemWithResponse(endpoint: endpoint, body: body);
        if((res.statusCode == 200 || res.statusCode == 201) && res.data is! String) {
          _storeService.clearCache();
          Fluttertoast.showToast(
              msg: "댓글이 등록되었습니다.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Color(0xff0baf00),
              textColor: Colors.white,
              fontSize: 16.0
          );
          await getComments();
          setState(() {
            _commentController.clear();
          });
        }
      } catch(e) {
        Fluttertoast.showToast(
            msg: "댓글등록 실패",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xffff0000),
            textColor: Colors.white,
            fontSize: 16.0
        );
        print(e);
      }
    }
  }
  Future<dynamic> _getSessionValue() async {
    sessionData = await secureStorage.readSecureData('session');
    Map<String, dynamic> sessionObject = jsonDecode(sessionData);
    setState(() {
      userId = sessionObject['success']['id'].toString();
    });

  }
  @override
  void initState() {
    super.initState();
    getComments();
    _getSessionValue();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: '댓글을 입력해주세요',
                  ),
                ),
              ),
              SizedBox(width:8),
              ElevatedButton(
                onPressed: _addComment,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0abf00),
                    minimumSize: Size(80,55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    )

                ),
                child: Text(
                  '저장',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'NotoSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500

                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,  // 이 속성을 변경
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,  // 이 줄을 추가
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comments[index]['nickname'],
                              style: TextStyle(
                                fontFamily: 'NotoSans',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${comments[index]['district']['state']} '
                              '${comments[index]['district']['city']} '
                              '${comments[index]['district']['district']} '
                              '${comments[index]['diff_at']}',
                              style: TextStyle(
                                fontFamily: 'NotoSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff666666),
                              ),
                            ),
                            Text(
                              comments[index]['content'],
                              style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 16,
                                  color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(  // IconButton을 Column으로 감싸기
                        mainAxisAlignment: MainAxisAlignment.start,  // 상단 정렬
                        children: [
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              _showOptions(context, index);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  void _showOptions(BuildContext context, int index) {
    Map<String,dynamic> commentItem = comments[index];
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(userId == commentItem['user_id'].toString() && true)
              ListTile(
                  leading: Icon(Icons.close),
                  title: Text('댓글 삭제'),
                  onTap: () => {
                    removeComment(commentItem['id']),
                    Navigator.pop(context)
                  }
              ),
            ListTile(
                leading: Icon(Icons.remove),
                title: Text('닫기'),
                onTap: () => {
                  Navigator.pop(context)
                }
            ),
            SizedBox(height: 10.0,)
          ],
        );
      },
    );
  }
  removeComment(String commentId) async {
    try {
      await _apiService.deleteItem(endpoint: endpoint, id: commentId);
    }catch(e) {
      print(e);
    }finally {
      await getComments();
    }
  }

}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../const/contents/content_type.dart';
import '../../service/api_service.dart';
import '../../service/contents/mapping_service.dart';
import '../../service/dependency_injecter.dart';
import '../../service/player_manager.dart';
import '../../store/secure_storage.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final _mappingService = MappingService();
  final secureStorage = getIt<SecureStorage>();
  String userId = '';
  late String sessionData;
  final double titleSize = 18.0;
  final double fontSize = 14.0;
  final String endpoint = 'audios-search';
  Timer? _debounce;
  bool _showCancelButton = false;
  int _categoryIndex = 1;
  final playerManager = getIt<PlayerManager>();
  List<bool> _selections = [true, false];
  List<dynamic> searchResults = [];
  List<String> recentSearches = ['광화문애가', '첫번째', '두번째'];

  //TODO delete demo
  final List<Map<String, dynamic>> searchPool = [
    {
      'type': ContentType.podcast,
      'imageUrl': 'asset/images/pngegg.png',
      'title': '첫번째',
      'subtitle': '자유마을과 함께하는 라디오타임',
      'isLive': true,
      'listerCount': 1700,
      'startTime': '14:00',
      'endTime': ''
    },
    {
      'type': ContentType.podcast,
      'imageUrl': 'asset/images/pngegg.png',
      'title': '두번째',
      'subtitle': '자유마을과 함께하는 라디오타임',
      'isLive': true,
      'listerCount': 1700,
      'startTime': '14:00',
      'endTime': ''
    },
    {
      'type': ContentType.music,
      'imageUrl': 'asset/images/music_jacket.png',
      'title': '광화문애가',
      'album': '광화문애가',
      'viewCount': 170000000,
      'shareCount': 23000,
      'subtitle': '눈물주의, 광화문에 한번이라도 나온 국민에게 위로가 되는 노래',
    },
    {
      'type': ContentType.podcast,
      'imageUrl': 'asset/images/pngegg.png',
      'title': '두번째',
      'subtitle': '자유마을과 함께하는 라디오타임',
      'isLive': true,
      'listerCount': 1700,
      'startTime': '14:00',
      'endTime': ''
    },
    {
      'type': ContentType.news,
      'imageUrl': 'asset/images/music_jacket.png',
      'title': '[걸리면 죽는다] 문재인 수사 문재인 수사',
      'subtitle': '눈물주의, 광화문에 한번이라도 나온 국민에게 위로가 되는 노래',
      'channel': '고성국TV',
      'viewCount': 170000,
      'shareCount': 23000
    },
    {
      'type': ContentType.podcast,
      'imageUrl': 'asset/images/pngegg.png',
      'title': '두번째',
      'subtitle': '자유마을과 함께하는 라디오타임',
      'isLive': true,
      'listerCount': 1700,
      'startTime': '14:00',
      'endTime': ''
    },
    {
      'type': ContentType.music,
      'imageUrl': 'asset/images/music_jacket.png',
      'title': '광화문애가',
      'album': '광화문애가',
      'viewCount': 170000000,
      'shareCount': 23000,
      'subtitle': '눈물주의, 광화문에 한번이라도 나온 국민에게 위로가 되는 노래',
    },
  ];

  Future<String> _getSessionValue() async {
    sessionData = await secureStorage.readSecureData('session');
    Map<String, dynamic> sessionObject = jsonDecode(sessionData);
    setState(() {
      userId = sessionObject['success']['id'].toString();
    });
    return userId;

  }
  Future<void> _search() async {
    Map<String, String> queries = {
      "category_id": "$_categoryIndex",
      "search": _searchController.text,
      "user_id": await _getSessionValue()
    };
    // print(queries);
    try {
      final searchData =
          await _apiService.fetchItems(endpoint: endpoint, queries: queries);
      // print('searchData:$searchData');
      setState(() {
        searchResults = _mappingService.mapItemsFromStoreList(searchData);
        _showCancelButton = true;
      });
    } catch (e) {
      print('Error loading bags: $e');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showCancelButton = false; // 취소 버튼 숨기기
      searchResults.clear(); // 검색 결과 초기화
    });
  }

  void _onTextChanged() {
    if (_searchController.text.isEmpty) {
      return;
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _search();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 32.0, left: 8.0, right: 8.0, bottom: 24.0),
          child: (Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '검색',
                  style: TextStyle(
                    fontFamily: 'NonoSans',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 48.0, left: 4.0, right: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: '컨텐츠, 보관함',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            // suffixIcon: IconButton(
                            //   icon: Icon(Icons.mic, color: Colors.grey),
                            //   onPressed: () {},
                            // ),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 10.0),
                          ),
                        ),
                      ),
                    ),
                    if (_showCancelButton)
                      TextButton(
                        onPressed: _clearSearch,
                        child:
                            Text('취소', style: TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
              ToggleButtons(
                borderRadius: BorderRadius.circular(10.0),
                selectedColor: Colors.white,
                fillColor: Color(0xff0baf00),
                color: Colors.black,
                borderColor: Colors.grey,
                selectedBorderColor: Colors.grey,
                constraints: BoxConstraints.expand(width: screenWidth / 2 - 20),
                isSelected: _selections,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selections.length; i++) {
                      _selections[i] = i == index;
                    }
                    _categoryIndex = index + 1;
                  });
                  if (_searchController.text.isNotEmpty) {
                    _search();
                  }
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      '컨텐츠',
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      '보관함',
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (searchResults.isEmpty && _searchController.text.isNotEmpty)
                Center(child:
                Text('항목이 없습니다')
                )
              else if (searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image.network(
                          searchResults[index]['imageUrl'],
                          fit: BoxFit.contain,
                          width: 60.0,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'asset/images/default_thumbnail.png',
                              width: 60.0,
                            );
                          },
                        ),
                        title: Text(
                            searchResults[index]['title'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: titleSize,
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              overflow: TextOverflow.ellipsis
                          ),
                        ),
                        subtitle: Text(
                            searchResults[index]['subtitle'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'NotoSans',
                              fontSize: fontSize,
                              height: 0.9
                          ),
                          softWrap: true,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            _showOptions(context);
                          },
                        ),
                        onTap: () => playerManager.addAndPlayItem(searchResults[index]),
                      );
                    },
                  ),
                )
              else
                Center(
                  child: Text('항목이 없습니다')
                )
                // Column(
                //   children: [
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text('최근 검색한 항목', style: TextStyle(fontSize: 18)),
                //         TextButton(
                //           onPressed: () {
                //             setState(() {
                //               recentSearches.clear();
                //             });
                //           },
                //           child: Text('지우기',
                //               style: TextStyle(color: Colors.green)),
                //         ),
                //       ],
                //     ),
                //     ...recentSearches.map((search) => ListTile(
                //           leading: Image.asset('asset/images/music_jacket.png'),
                //           title: Text(search),
                //           subtitle: Text('음원 - 광화문레코드'),
                //           trailing: IconButton(
                //             icon: Icon(Icons.more_vert),
                //             onPressed: () {
                //               _showOptions(context);
                //             },
                //           ),
                //         )),
                //   ],
                // )
            ],
          )),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text('보관함에 추가'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('바로 재생'),
              onTap: () {},
            ),
            // ListTile(
            //   leading: Icon(Icons.share),
            //   title: Text('공유'),
            //   onTap: () {},
            // ),
            SizedBox(height: 10,)
          ],
        );
      },
    );
  }
}

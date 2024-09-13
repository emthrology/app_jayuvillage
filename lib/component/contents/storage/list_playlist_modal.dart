import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../service/api_service.dart';
import '../../../service/dependency_injecter.dart';
import '../../../store/store_service.dart';

class ListPlaylistModal extends StatefulWidget {
  final List<dynamic> playlists;
  final String audio_id;
  const ListPlaylistModal({super.key, required this.playlists, required this.audio_id});

  @override
  State createState() => _ListPlaylistModalState();
}

class _ListPlaylistModalState extends State<ListPlaylistModal> {
  int? _selectedIndex;
  final _storeService = getIt<StoreService>();
  final ApiService _apiService = ApiService();
  final double titleSize = 24.0;
  final double fontSize = 18.0;
  final String endpoint = 'bags';
  void _selectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // print('selectedItem:${widget.playlists[index]}');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('닫기', style: TextStyle(fontSize: 18)),
                ),
                Text('보관함',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () async {
                    if(_selectedIndex == null) {
                      Fluttertoast.showToast(
                          msg: "보관함을 먼저 선택해주세요",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Color(0xffff0000),
                          textColor: Colors.white,
                          fontSize: 22.0
                      );
                    }
                    Map<String, dynamic> body = {
                      'audio_id': widget.audio_id,
                      'bag_item_id': widget.playlists[_selectedIndex!]['id']
                    };
                    String completeWord = '보관 작업이 ';
                    try {
                      Response res = await _apiService.postItemWithResponse(endpoint: endpoint, body: body);
                      // print('res:$res');
                      if((res.statusCode == 200 || res.statusCode == 201) && res.data is! String) {
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
                    }
                  },
                  child: Text('선택 완료',
                      style: TextStyle(fontSize: 18, color: Colors.green)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.playlists.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      widget.playlists[index]['title'],
                      style: TextStyle(fontSize: titleSize),
                    ),
                    trailing: _selectedIndex == index
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.circle_outlined),
                    onTap: () => _selectItem(index),
                    selected: _selectedIndex == index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

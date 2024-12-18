import 'dart:convert';

import 'package:flutter/material.dart';

import '../../service/api_service.dart';
import '../../service/app_router.dart';
import '../../service/dependency_injecter.dart';
import '../../store/secure_storage.dart';

class ExMenusIndex extends StatefulWidget {
  const ExMenusIndex({super.key});

  @override
  State<ExMenusIndex> createState() => _ExMenusIndexState();
}

class _ExMenusIndexState extends State<ExMenusIndex> {
  final ApiService _apiService = ApiService();
  final secureStorage = getIt<SecureStorage>();
  Map<String, dynamic>? session;
  late String position;
  List<dynamic> menuList = [
    {
      'id':'0',
      'menuTitle':'조직현황'
    },
    {
      'id':'1',
      'menuTitle':'물류현황'
    },
  ];
  List<dynamic> itemMenuList = [
    {
      'id':'10',
      'category':'item',
      'menuTitle':'파라솔'
    },
  ];
  bool _itemListVisible = false;

  Future<void> _getSessionValue() async {
    var sessionData = await secureStorage.readSecureData('session');
    Map<String, dynamic> sessionObject = jsonDecode(sessionData);
    final positionData = sessionObject['success']['position'];
    debugPrint('_getSessionValue_position:$positionData');
    setState(() {
      session = sessionObject['success'];
      position = positionData;
    });
  }
  @override
  void initState() {
    super.initState();
    _getSessionValue();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    // session != null ?
                    // '${session!['position']} : ${session!['name']}' : '',
                    '내 지역 활동',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height:40),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => onCardTap(menuList[index]['id']),
                        child: Card(
                          color: Color(0xff0baf00),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                            child: Center(
                              child: Text(
                                '${menuList[index]['menuTitle']}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                ),
                Flexible(
                  flex: 4,
                    child:
                    // _itemListVisible ?
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      height: _itemListVisible ? 210 : 0,
                      child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => onCardTap(itemMenuList[index]['id']),
                          child: Card(
                            color: Color(0xff58a7b3),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                              child: Center(
                                child: Text(
                                  '${itemMenuList[index]['menuTitle']}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                                      ),
                    )
                        // : SizedBox(),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Semantics(
                    label: '뒤로가기',
                    hint: '이전 화면으로 가기 위해 누르세요',
                    child: GestureDetector(
                      onTap: _onBackTapped,
                      child: Row(children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 32.0,
                        ),
                      ]),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void onCardTap(String idString) {
    int id = int.parse(idString);
    debugPrint('exMenusIndex_onCardTap:$id');
    if(id == 0) {
      goRouter.push('/organization/manager/items/$id');
    }
    if(id == 1) {
      setState(() {
        _itemListVisible = true;
      });
    }
    if(id > 9) {
      final String phone = session!['phone'];
      goRouter.push('/organization/manager/items/$id?position=$position&phone=$phone');
    }
  }
  void _onBackTapped() {
    goRouter.go('/organization');
  }
}

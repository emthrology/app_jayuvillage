import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:webview_ex/component/organization_manage/main_data_card.dart';
class ManageHomeScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  final VoidCallback onEventScreenTap;
  const ManageHomeScreen({super.key, required this.sessionData, required this.onEventScreenTap});

  @override
  State<ManageHomeScreen> createState() => _ManageHomeScreenState();
}

class _ManageHomeScreenState extends State<ManageHomeScreen> {
  Map<String, dynamic> branchManagerCardData = {
    'position':'실행위원장',
    'manage':{
      'total': 13,
      'connected': 13,
      'disconnected':0
    },
    'total': {
      'total': 255,
      'connected':255,
      'disconnected':0
    }
  };
  Map<String, dynamic> managerCardData = {
    'position':'마을대표',
    'manage':{
      'total': 191,
      'connected': 190,
      'disconnected':1
    },
    'total': {
      'total': 3528,
      'connected':3255,
      'disconnected':263
    }
  };

@override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 0.0, left: 8.0, right: 8.0, bottom: 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:8.0),
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width/10,
                    ),
                    child: Text(
                      '조직관리 관리자메뉴',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              ),
              //상단 프로필정보 컴포넌트
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 96,
                      width: 96,
                      child: Padding(
                        padding: const EdgeInsets.only(right:8.0),
                        child: CircleAvatar(
                          radius: 64.0,
                          backgroundColor: Colors.redAccent,
                          child: Text(
                            '${widget.sessionData['name'].split('').first}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '경기1 / ${widget.sessionData['position']} / ${widget.sessionData['name']}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          Text(
                            '204명 중 191명',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            '관리대상 실시간 접속현황',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      )
                    )
                  ],
                ),
              ),
              //임원 전체 접속현황
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('임원전체 접속현황',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    Text(
                      '3794명 중 3531명',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32,),
              // 조직데이터 타이틀
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('조직데이터 분석',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              blurRadius: 1.0,
                              color: Colors.black,
                              offset: Offset(0.1, 0.1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width:5),
                      Container(
                        height: 22,
                        color: Colors.red,
                        child: Row(
                          children: [
                            Icon(MdiIcons.accessPoint, color: Colors.white,),
                            Text('실시간',
                              style: TextStyle(
                                  backgroundColor: Colors.red,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Text(getFormattedDate(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              MainDataCard(cardData: branchManagerCardData),
              SizedBox(height: 16,),
              MainDataCard(cardData: managerCardData),
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        constraints: BoxConstraints(
                            minHeight: 64,
                            minWidth: MediaQuery.of(context).size.width/2 - 40
                        ),
                        child: GestureDetector(
                          onTap: () => widget.onEventScreenTap(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('집회 및 모임',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('참석률',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(

                        constraints: BoxConstraints(
                          minHeight: 64,
                          minWidth: MediaQuery.of(context).size.width/2 - 40
                        ),
                        child: Center(
                          child: Text('가입사항 확인',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  String getFormattedDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM/dd').format(now);
    return formattedDate;
  }
}

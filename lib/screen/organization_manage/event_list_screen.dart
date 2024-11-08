import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_ex/component/organization_manage/event_list_card.dart';

class EventListScreen extends StatefulWidget {
  final String type;
  final String title;
  final VoidCallback onCalendarCalled;

  const EventListScreen(
      {super.key,
      required this.type,
      required this.title,
      required this.onCalendarCalled});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<dynamic> sampleData = [
    {
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
    },
    {
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
    },
    {
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
    },
    {
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
    }
  ];
  List<dynamic> eventSampleData = [
    {
      'title': '11월3일 국민대회 · 광화문',
      'date': '2024/11/03',
      'branch_manager': {'total': 255, 'attended': 188, 'avoided': 67},
      'manager': {'total': 1500, 'attended': 1250, 'avoided': 250}
    },
    {
      'title': '11월13일 국민대회 · 광화문',
      'date': '2024/11/13',
      'branch_manager': {'total': 255, 'attended': 188, 'avoided': 67},
      'manager': {'total': 1500, 'attended': 1250, 'avoided': 250}
    },
    {
      'title': '11월23일 국민대회 · 광화문',
      'date': '2024/11/23',
      'branch_manager': {'total': 255, 'attended': 188, 'avoided': 67},
      'manager': {'total': 1500, 'attended': 1250, 'avoided': 250}
    },
    {
      'title': '11월30일 국민대회 · 광화문',
      'date': '2024/11/30',
      'branch_manager': {'total': 255, 'attended': 188, 'avoided': 67},
      'manager': {'total': 1500, 'attended': 1250, 'avoided': 250}
    },
  ];
  List<dynamic> checkSampleData = [
    {
      'title': '설문16호 참석여부',
      'date': '2024/11/03',
      'branch_manager': {'total': 255, 'attended': 188, 'avoided': 67},
      'manager': {'total': 1500, 'attended': 1250, 'avoided': 250}
    },
    {
      'title': '설문17호 참석여부',
      'date': '2024/11/13',
      'branch_manager': {'total': 255, 'attended': 188, 'avoided': 67},
      'manager': {'total': 1500, 'attended': 1250, 'avoided': 250}
    },
    {
      'title': '설문18호 참석여부',
      'date': '2024/11/25',
      'branch_manager': {'total': 255, 'attended': 188, 'avoided': 67},
      'manager': {'total': 1500, 'attended': 1250, 'avoided': 250}
    },
    {
      'title': '공지 20호 참석여부',
      'date': '2024/11/30',
      'branch_manager': {'total': 255, 'attended': 188, 'avoided': 67},
      'manager': {'total': 1500, 'attended': 1250, 'avoided': 250}
    },
  ];

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
                padding: const EdgeInsets.only(bottom: 8.0),
                // menuTitle
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 10,
                    ),
                    child: Text(
                      widget.title,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Semantics(
                      label: '달력 화면',
                      hint: '달력화면으로 가기 위해 누르세요',
                      child: GestureDetector(
                        onTap: () => widget.onCalendarCalled(),
                        child: Row(children: [
                          Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.red,
                            size: 32.0,
                          ),
                          Text(
                            getFormattedDate(),
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.red,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  itemCount: sampleData.length,
                  itemBuilder: (BuildContext ctx, int idx) {
                    return EventListCard(cardData: sampleData[idx]);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy년 MM월').format(now);
    return formattedDate;
  }
}

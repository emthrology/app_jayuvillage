import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_ex/store/store_service.dart';

import '../../../component/custom_alert_component.dart';
import '../../../component/organization_item_status/district_list_card.dart';
import '../../../const/dialog_type.dart';
import '../../../service/api_service.dart';
import '../../../service/app_router.dart';
import '../../../service/dependency_injecter.dart';
import '../../../store/secure_storage.dart';

class BranchManagerItemlist extends StatefulWidget {
  final String phone;

  const BranchManagerItemlist({super.key, required this.phone});

  @override
  State<BranchManagerItemlist> createState() => _BranchManagerItemlistState();
}

class _BranchManagerItemlistState extends State<BranchManagerItemlist> {
  final ApiService _apiService = ApiService();
  late List<dynamic> districtList;
  late List<Map<String, dynamic>> districtCountList;
  final storeService = getIt<StoreService>();
  final secureStorage = getIt<SecureStorage>();
  bool _parasolSelected = false;
  int selectedDistrictCount = 0;
  bool _isLoading = true;
  Map<String, dynamic> branchManagerProfileData = {
    'me': {},
    'boss': {},
    'data': []
  };

  Future<void> getDistrictList(String phone) async {
    final result = await _apiService.fetchItems(
      endpoint: 'drafts/mid-list',
      queries: {'phone': phone},
      useCache: false,
      useWhole: true,
    );
    districtList = result[0]['districts'];
    setState(() {
      branchManagerProfileData = {
        'boss': result[0]['boss'],
        'me': result[0]['me'],
        'data': result[0]['data']
      };
      // _pages = [
      //   BranchManagerChecklist(profileData: branchManagerProfileData, onCardTap: (districtName, districtId) => selectDistrict(districtName, districtId),),
      //   ManagerChecklist(profileData: branchManagerProfileData)
      // ];
      getDistrictCountList(result[0]['data']);
      _isLoading = false;
    });
  }

  void getDistrictCountList(List<dynamic> originalList) {
    // print(originalList);
    // draft_district_id별로 카운트를 저장할 Map 선언
    Map<int, Map<String, dynamic>> districtCountMap = {};

    // 데이터를 순회하면서 draft_district_id별로 카운트 증가 및 데이터 추가
    for (var item in originalList) {
      int districtId = item['draft_district_id'];

      if (districtCountMap.containsKey(districtId)) {
        // 이미 존재하는 경우 count 증가 및 data 리스트에 추가
        districtCountMap[districtId]!['parasol_count'] += item['parasol_count'];
        districtCountMap[districtId]!['count'] += 1;
        districtCountMap[districtId]!['data'].add(item);
      } else {
        // 처음 발견된 경우 새로운 항목 생성
        districtCountMap[districtId] = {
          'district': item['district'],
          'district_id': districtId,
          'count': 1,
          'parasol_count': item['parasol_count'],
          'data': [item], // 데이터를 리스트 형태로 추가
        };
      }
    }
    // for (var item in districtList) {
    //   int districtId = item['id'];
    //   if (!districtCountMap.containsKey(districtId)) {
    //     districtCountMap[districtId] = {
    //       'district': item['district'],
    //       'district_id': districtId,
    //       'count': 0,
    //       'parasol_count':1,
    //       'data': null
    //     };
    //   }
    // }
    districtCountList = districtCountMap.values.toList();
    int totalParasolCount = districtCountList.fold(0, (sum, map) {
      // return (sum + (map['parasol_count'] ?? 0)).toInt(); // null 값 처리
      return (sum + (map['parasol_count'] > 0 ? 1 : 0)).toInt(); // null 값 처리
    });
    branchManagerProfileData['me']['count'] = districtList.length;
    branchManagerProfileData['me']['parasol_count'] = totalParasolCount;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDistrictList(widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 0.0, left: 8.0, right: 8.0, bottom: 24.0),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              '${branchManagerProfileData['boss']['draft_state_name']} 파라솔 현황',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            width: MediaQuery.of(context).size.width - 20,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.black26,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                    strokeAlign:
                                        BorderSide.strokeAlignCenter),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                                ],
                                color: Colors.grey.shade300),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${branchManagerProfileData['me']['position']}: ${branchManagerProfileData['me']['name']}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'NotoSans',
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '파라솔 ${branchManagerProfileData['me']['parasol_count']}개 / 마을 ${branchManagerProfileData['me']['count']}개',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'NotoSans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        debugPrint(
                                            'tel:${branchManagerProfileData['me']['phone']}');
                                        if (Platform.isAndroid) {
                                          _launchURL(
                                              'tel:${branchManagerProfileData['me']['phone']}');
                                        } else if (Platform.isIOS) {
                                          makeSupportCall(
                                              'tel:${branchManagerProfileData['me']['phone']}');
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Color(0xff0baf00),
                                            size: 32,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          if(!_parasolSelected)
                            Column(
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700
                                    ),
                                    children: [
                                      TextSpan(text:'파라솔이 필요한 경우\n'),
                                      TextSpan(text:'배송 신청하기',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700
                                        ),
                                      ),
                                      TextSpan(text:'를 눌러주세요')
                                    ]
                                  )
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _parasolSelected = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:Colors.blue.shade700,
                                        foregroundColor:  Colors.white,
                                        elevation:1,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width-20,
                                            50
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        )
                                    ),
                                    child: Text(
                                      '배송 신청하기',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600
                                      ),
                                    )
                                )
                              ],
                            ),
                          if(_parasolSelected)
                            Column(
                              children: [
                                Text(
                                  '파라솔이 필요한\n마을을 선택해주세요',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        confirmReservationAlert();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:Colors.lightBlueAccent,
                                        foregroundColor:  Colors.white,
                                        elevation:1,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width-20,
                                            50
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        )
                                    ),
                                    child: Text(
                                      '$selectedDistrictCount 개 배송 신청하기',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600
                                      ),
                                    )
                                )
                              ],
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: 3 / 1.4),
                              itemCount: districtCountList.length,
                              itemBuilder: (context, index) =>
                                  GestureDetector(
                                onTap: () => selectDistrict(
                                    districtCountList[index]['district'],
                                    districtCountList[index]
                                        ['district_id']),
                                child: DistrictListCard(
                                    listItem: districtCountList[index], editable: _parasolSelected),
                              ),
                            ),
                          )
                        ],
                      ),
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
        ));
  }

  void _onBackTapped() {
    goRouter.pop();
  }
  //마을 선택 토글 기능
  void selectDistrict(String districtName, int districtId) {
    final int index = districtCountList.indexWhere((item) => item['district_id'] == districtId);
    if(_parasolSelected == false) return;
    if(districtCountList[index]['parasol_count'] > 0) return;
    setState(() {
      if(districtCountList[index]['selected'] != null) {
        districtCountList[index]['selected'] = !districtCountList[index]['selected'];
      }else {
        districtCountList[index]['selected'] = true;
      }
      selectedDistrictCount = districtCountList.where((item) => item['selected'] == true).toList().length;
    });
  }

  void confirmReservationAlert() {
    final selectedDistricts = districtCountList.where((item) => item['selected'] == true).toList();
    final districtNames = selectedDistricts.map((item) => item['district'].toString()).join(',');
    final districtIds = selectedDistricts.map((item) => item['district_id']).toList();
    final String state = branchManagerProfileData['me']['state'];
    final String election = branchManagerProfileData['me']['draft_election_name'];
    storeService.setPrefs('parasolDistricts', jsonEncode(districtIds));
    storeService.setPrefs('parasolProfileData', jsonEncode(branchManagerProfileData));
    showDialog(
      context: context,
      builder: (ctx) => CustomAlertDialog(
        dialogInfo: {
          'dialogType': DialogType.success,
          'title': '파라솔 배송 마을 선택',
          'message': '${selectedDistricts.length}개를 신청하시겠습니까?\n 신청마을:$districtNames',
          'buttonInfo': [
            {
              'btnTitle': '아니오',
              'btnColor': Colors.white,
              'fontColor': Colors.black,
              'onPressed': () => Navigator.of(context).pop()
            },
            {'btnTitle': '예', 'onPressed': () {
              //TODO do job here
              goRouter.push('/organization/manager/address?state=$state&election=$election');
              Navigator.of(context).pop();
            }}
          ]
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('cannot launch url');
      throw 'Could not launch $url';
    }
  }

  Future<void> makeSupportCall(String url) async {
    final regex = RegExp(r'^tel:(\d{3})(\d{4})(\d{4})$');
    if (regex.hasMatch(url)) {
      final match = regex.firstMatch(url);
      if (match != null) {
        url = '${match.group(1)}${match.group(2)}${match.group(3)}';
      }
    }
    try {
      await FlutterPhoneDirectCaller.callNumber(url);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }
}

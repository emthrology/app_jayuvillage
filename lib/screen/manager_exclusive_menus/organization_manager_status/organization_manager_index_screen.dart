import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_ex/screen/manager_exclusive_menus/organization_manager_status/branch_manager_checklist.dart';
import 'package:webview_ex/screen/manager_exclusive_menus/organization_manager_status/general_manager_checklist.dart';
import 'package:webview_ex/screen/manager_exclusive_menus/organization_manager_status/manager_checklist.dart';

import '../../../service/api_service.dart';
import '../../../service/app_router.dart';
import '../../../service/dependency_injecter.dart';
import '../../../store/secure_storage.dart';




class OrganizationManagerIndexScreen extends StatefulWidget {
  const OrganizationManagerIndexScreen({super.key});

  @override
  State<OrganizationManagerIndexScreen> createState() =>
      _OrganizationManagerIndexScreenState();
}

class _OrganizationManagerIndexScreenState
    extends State<OrganizationManagerIndexScreen> {
  int _currentPageDepth = 0;
  final ApiService _apiService = ApiService();
  final secureStorage = getIt<SecureStorage>();
  late String position;
  late List<Widget> _pages;
  late Map<String, dynamic> profileData;
  Map<String, dynamic> branchManagerProfileData = {'me':{},'boss':{},'data':[]};
  late List<dynamic> reducedList;
  List<dynamic> managerList = [];
  bool _isLoading = true;

  late List<dynamic> testList;

  Future<void> _getSessionValue() async {
    var sessionData = await secureStorage.readSecureData('session');
    Map<String, dynamic> sessionObject = jsonDecode(sessionData);
    position = sessionObject['success']['position'];
    var phone = sessionObject['success']['phone'];
    print('position:$position');
    if(position == '총괄팀장') {
      await getBranchManagerList();
    }else if(position == '실행위원장') {
      await getDistrictList(phone);
    }
  }
  Future<void> getBranchManagerList() async {
    final result = await _apiService.fetchItems(
      endpoint: 'drafts/draft-list',
      useCache: false,
      useWhole: true,
    );
    profileData = result[0]['me'];
    reducedList = result[0]['data']
        .where((managerItem) => managerItem['position'] == '실행위원장')
        .toList();
    setState(() {
      managerList = result[0]['data']
          .where((managerItem) => managerItem['position'] == '동대표')
          .toList();
    });
    for (var manager in managerList) { //동대표 리스트
      for (var item in reducedList) { // 실행위원장 리스트
        // item.update('districtCount',(_) => 7, ifAbsent: () => 7);
        if (item['draft_election_name'] == manager['draft_election_name']) {
          item.update('managerCount', (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }
    _pages = [
      GeneralManagerChecklist(
        profileData: profileData,
        managerList: reducedList,
        onCardTap: (id) => selectBranchManager(id),
      ),
      BranchManagerChecklist(profileData: branchManagerProfileData, onCardTap: (districtName, districtId) => selectDistrict(districtName, districtId),),

    ];
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> getDistrictList(String phone) async {
    final result = await _apiService.fetchItems(
      endpoint: 'drafts/mid-list',
      queries: {'phone':phone},
      useCache: false,
      useWhole: true,
    );
    setState(() {
      branchManagerProfileData = {
        'boss': result[0]['boss'],
        'me': result[0]['me'],
        'data': result[0]['data']
      };
      _pages = [
        BranchManagerChecklist(profileData: branchManagerProfileData, onCardTap: (districtName, districtId) => selectDistrict(districtName, districtId),),
        ManagerChecklist(profileData: branchManagerProfileData)
      ];
      _isLoading = false;
    });
  }
  void selectBranchManager(int id) {
    String selectedElectionName = reducedList.firstWhere((manager) => manager['id'] == id)['draft_election_name'];
    setState(() {
      branchManagerProfileData = {
        'boss': profileData,
        'me': reducedList.firstWhere((manager) => manager['id'] == id),
        'data': managerList.where((manager) => manager['draft_election_name'] == selectedElectionName).toList()
      };
      _pages = [
        GeneralManagerChecklist(
          profileData: profileData,
          managerList: reducedList,
          onCardTap: (id) => selectBranchManager(id),
        ),
        BranchManagerChecklist(profileData: branchManagerProfileData, onCardTap: (districtName, districtId) => selectDistrict(districtName, districtId),),
        ManagerChecklist(profileData: branchManagerProfileData)
      ];
      _currentPageDepth++;
    });

  }
  void selectDistrict(String districtName, int districtId) {
    List<dynamic> selectedManagerList =  branchManagerProfileData['data'].where((manager) => manager['district'] == districtName).toList();
    setState(() {
      branchManagerProfileData = {
        'boss': branchManagerProfileData['boss'],
        'me': branchManagerProfileData['me'],
        'data': branchManagerProfileData['data'],
        'selectedDistrict': districtName,
        'selectedDistrictId': districtId,
        'selectedManagerList': selectedManagerList
      };
      if(position == '총괄팀장') {
        _pages = [
          GeneralManagerChecklist(
            profileData: profileData,
            managerList: reducedList,
            onCardTap: (id) => selectBranchManager(id),
          ),
          BranchManagerChecklist(profileData: branchManagerProfileData, onCardTap: (districtName, districtId) => selectDistrict(districtName, districtId),),
          ManagerChecklist(profileData: branchManagerProfileData)
        ];
      }else if(position == '실행위원장') {
        _pages = [
          BranchManagerChecklist(profileData: branchManagerProfileData, onCardTap: (districtName, districtId) => selectDistrict(districtName, districtId),),
          ManagerChecklist(profileData: branchManagerProfileData)
        ];
      }
      _currentPageDepth++;
    });
  }
  @override
  void initState() {
    super.initState();
    // getBranchManagerList();
    _getSessionValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  // profileData['position'] == '총괄팀장'
                  //     ? GeneralManagerChecklist(
                  //         profileData: profileData,
                  //         managerList: reducedList,
                  //       )
                  //     : BranchManagerChecklist(profileData: profileData),
                  _pages[_currentPageDepth],
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

  void _onBackTapped() {
    if (_currentPageDepth == 0) {
      goRouter.go('/organization');
    } else if (_currentPageDepth > 0) {
      setState(() {
        _currentPageDepth--;
      });
    } else {
      goRouter.pop();
    }
  }
}

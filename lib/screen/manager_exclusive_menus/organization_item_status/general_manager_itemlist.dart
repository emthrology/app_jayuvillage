import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../component/organization_item_status/branch_list_card.dart';
import '../../../service/api_service.dart';
import '../../../service/app_router.dart';
import '../../../service/dependency_injecter.dart';
import '../../../store/secure_storage.dart';

class GeneralManagerItemlist extends StatefulWidget {
  const GeneralManagerItemlist({super.key});

  @override
  State<GeneralManagerItemlist> createState() => _GeneralManagerItemlistState();
}

class _GeneralManagerItemlistState extends State<GeneralManagerItemlist> {
  final ApiService _apiService = ApiService();
  final secureStorage = getIt<SecureStorage>();
  late Map<String, dynamic> profileData;
  late List<dynamic> reducedList;
  List<dynamic> managerList = [];
  bool _isLoading = true;

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
    // for (var manager in managerList) { //동대표 리스트
    //   for (var item in reducedList) { // 실행위원장 리스트
    //     // item.update('districtCount',(_) => 7, ifAbsent: () => 7);
    //     if (item['draft_election_name'] == manager['draft_election_name']) {
    //       debugPrint('manager:$manager');
    //       debugPrint('manager_parasol_count:${manager['parasol_count']}');
    //       item.update('districtCount', (value) => value + 1, ifAbsent: () => 0);
    //       item.update('parasol_count', (value2) => value2 + manager['parasol_count'], ifAbsent: () => 0);
    //       debugPrint('loop_manager_parasol_count:${manager['parasol_count']}');
    //       debugPrint('loop_parasol_count:${item['parasol_count']}');
    //     }
    //   }
    // }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBranchManagerList();
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
                  : Column( children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        // '${profileData['draft_state_name']} ${profileData['position']}: ${profileData['name']}',
                        '파라솔 ${reducedList.fold(0, (cur, acc) => (cur + (acc['parasol_count'] ?? 0)).toInt())}개 / 마을 ${reducedList.fold(0, (cur, acc) => (cur + (acc['count'] ?? 0)).toInt())}개',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 24,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  SizedBox(height: 10),
                  Expanded(
                      child: ListView.builder(
                        itemCount: reducedList.length,
                        itemBuilder: (BuildContext ctx, int idx) {
                          return GestureDetector(
                              onTap: () => selectBranchManager(reducedList[idx]['id']),
                              child: BranchListCard(listItem: reducedList[idx]));
                        },
                      ))
                ],)
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
          )
      ),
    );
  }
  void _onBackTapped() {
    goRouter.pop();
  }
  void selectBranchManager(int id) {
    Map<String, dynamic> selectedElection = reducedList.firstWhere((manager) => manager['id'] == id);
    String branchManagerPhone = selectedElection['phone'];
    goRouter.push('/organization/manager/items/10?phone=$branchManagerPhone');
  }
}

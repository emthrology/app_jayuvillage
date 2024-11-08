import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_ex/component/organization_manager_status/district_list_card.dart';

import '../../service/api_service.dart';

class BranchManagerChecklist extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final Function(String districtName, int districtId) onCardTap;
  const BranchManagerChecklist({super.key, required this.profileData, required this.onCardTap});

  @override
  State<BranchManagerChecklist> createState() => _BranchManagerChecklistState();
}

class _BranchManagerChecklistState extends State<BranchManagerChecklist> {
  final ApiService _apiService = ApiService();
  late List<dynamic> districtList;
  late List<Map<String, dynamic>> districtCountList;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    getDistrictList();
    // getDistrictCountList(widget.profileData['data']);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 0.0, left: 8.0, right: 8.0, bottom: 24.0),
      child: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
                '${widget.profileData['boss']['draft_state_name']} ${widget.profileData['boss']['position']}: ${widget.profileData['boss']['name']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(horizontal:8, vertical: 8),
            width: MediaQuery.of(context).size.width - 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.black26,
                  width: 1.0,
                  style: BorderStyle.solid,
                  strokeAlign: BorderSide.strokeAlignCenter
              ),
              boxShadow:[
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2))
              ],
              color: Colors.grey.shade300
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.profileData['me']['position']}: ${widget.profileData['me']['name']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 22,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      '마을개수 ${widget.profileData['me']['count']}개 / 동대표 ${widget.profileData['me']['managerCount']}명',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('tel:${widget.profileData['me']['phone']}');
                        if (Platform.isAndroid) {
                          _launchURL('tel:${widget.profileData['me']['phone']}');
                        } else if (Platform.isIOS) {
                          makeSupportCall('tel:${widget.profileData['me']['phone']}');
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
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 10,
                childAspectRatio: 2 / 1.4
              ),
              itemCount: districtCountList.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => widget.onCardTap(districtCountList[index]['district'], districtCountList[index]['district_id']),
                child: DistrictListCard(listItem: districtCountList[index]),
              ),
            ),
          )
        ],
      ),
    );
  }
  Future<void> getDistrictList() async {
    final result = await _apiService.fetchItems(
        endpoint: 'drafts/mid-list',
        queries: {'phone':'${widget.profileData['me']['phone']}'},
        useCache: false,
        useWhole: true,
    );
    districtList = result[0]['districts'];
    getDistrictCountList(widget.profileData['data']);
    setState(() {
      if(widget.profileData['me']['count'] == null) {
        widget.profileData['me']['count'] = districtList.length;
        widget.profileData['me']['managerCount'] = widget.profileData['data'].length;
      }
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
        districtCountMap[districtId]!['count'] += 1;
        districtCountMap[districtId]!['data'].add(item);
      } else {
        // 처음 발견된 경우 새로운 항목 생성
        districtCountMap[districtId] = {
          'district':item['district'],
          'district_id': districtId,
          'count': 1,
          'data': [item], // 데이터를 리스트 형태로 추가
        };
      }
    }
    for(var item in districtList) {
      int districtId = item['id'];
      if(!districtCountMap.containsKey(districtId)) {
        districtCountMap[districtId] = {
          'district': item['district'],
          'district_id':districtId,
          'count': 0,
          'data': null
        };
      }
    }
    districtCountList =  districtCountMap.values.toList();
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

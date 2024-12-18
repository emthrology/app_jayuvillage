import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_ex/component/organization_manager_status/manager_list_card.dart';

import '../../../component/organization_manager_status/phone_button.dart';
import '../../../service/api_service.dart';



class ManagerChecklist extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const ManagerChecklist({super.key, required this.profileData});

  @override
  State<ManagerChecklist> createState() => _ManagerChecklistState();
}

class _ManagerChecklistState extends State<ManagerChecklist> {
  final ApiService _apiService = ApiService();
  late List<dynamic> selectedDistrictList;
  late List<bool> _expanded;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDistrictList = widget.profileData['selectedManagerList'];
    if (widget.profileData['selectedManagerList'].isNotEmpty) {
      getManagerSupervisors();
    } else {
      _isLoading = false;
    }
  }

  Future<void> getManagerSupervisors() async {
    final result = await _apiService.fetchItems(
      endpoint: 'drafts/low-list',
      queries: {
        'draft_district_id': '${widget.profileData['selectedDistrictId']}'
      },
    );
    setState(() {
      selectedDistrictList = result;
      _expanded = List.filled(selectedDistrictList.length, false);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.only(
                top: 0.0, left: 8.0, right: 8.0, bottom: 24.0),
            child: Column(
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
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '마을개수 ${widget.profileData['me']['count']}개 / 동대표 ${widget.profileData['me']['managerCount']}명',
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
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: GestureDetector(
                            onTap: () {
                              debugPrint(
                                  'tel:${widget.profileData['me']['phone']}');
                              if (Platform.isAndroid) {
                                _launchURL(
                                    'tel:${widget.profileData['me']['phone']}');
                              } else if (Platform.isIOS) {
                                makeSupportCall(
                                    'tel:${widget.profileData['me']['phone']}');
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Color(0xff0baf00),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    '${widget.profileData['selectedDistrict']} 대표: ${selectedDistrictList.length}명',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                if (selectedDistrictList.isNotEmpty)
                  Expanded(
                      child: ListView.builder(
                          itemCount: selectedDistrictList.length,
                          itemBuilder: (BuildContext ctx, int idx) {
                            return Column(
                              children: [
                                ManagerListCard(
                                  listItem: selectedDistrictList[idx],
                                  onTap: () {
                                    if(selectedDistrictList[idx]['supervisors'] != null) {
                                      setState(() {
                                        _expanded[idx] =
                                            !_expanded[idx]; // 클릭 시 확장 상태 토글
                                      });
                                    }
                                  },
                                ),
                                SizedBox(height: 5,),
                                if (_expanded[idx])
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey[200],

                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: Column(
                                        children: selectedDistrictList[idx]
                                                ['supervisors']
                                            .map<Widget>((member) {
                                          return ListTile(
                                            title: Text(
                                              member['name'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600
                                              ),
                                            ),
                                            trailing: SizedBox(
                                                width: 95,
                                                child: PhoneButton(phoneNumber: member['phone']))
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                              ],
                            );
                          }))
              ],
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

import 'dart:convert';
import 'dart:io';

import 'package:daum_postcode_view/daum_postcode_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_ex/service/api_service.dart';

import '../../../component/custom_alert_component.dart';
import '../../../const/dialog_type.dart';
import '../../../service/app_router.dart';
import '../../../service/dependency_injecter.dart';
import '../../../store/store_service.dart';

class SearchDeliveryAddressScreen extends StatefulWidget {
  final String state;
  final String election;

  const SearchDeliveryAddressScreen(
      {super.key, required this.state, required this.election});

  @override
  State<SearchDeliveryAddressScreen> createState() =>
      _SearchDeliveryAddressScreenState();
}

class _SearchDeliveryAddressScreenState
    extends State<SearchDeliveryAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final storeService = getIt<StoreService>();
  late List<dynamic> districts;
  late Map<String, dynamic> branchManagerProfileData;
  bool _isLoading = true;

  Future<void> getParasolDistricts() async {
    String? jsonData = await storeService.getPrefs('parasolDistricts');
    String? parasolProfileData =
        await storeService.getPrefs('parasolProfileData');
    districts = jsonDecode(jsonData!);
    branchManagerProfileData = jsonDecode(parasolProfileData!);
    print('$districts');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getParasolDistricts();
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          width: MediaQuery.of(context).size.width - 20,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.black26,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                  strokeAlign: BorderSide.strokeAlignCenter),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2))
                              ],
                              color: Colors.grey.shade300),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    borderRadius: BorderRadius.circular(5)),
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
                        Text(
                          '파라솔 ${districts.length}개를 수령할\n주소를 선택해주세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700
                          ),
                        ),
                        SizedBox(height: 20,),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _openAddressSearch,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    labelText: '주소',
                                    hintText: '주소를 검색하세요',
                                    suffixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _address2Controller,
                              decoration: InputDecoration(
                                labelText: '상세 주소',
                                hintText: '상세 주소를 검색하세요',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40,),
                        ElevatedButton(
                            onPressed: () => sendRequest(context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:Color(0xff0baf00),
                                foregroundColor: Colors.white,
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
                              '입력 완료',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                        ),
                        SizedBox(height: 40,),
                        Text(
                          '주의사항\n\n1.파라솔은 마을별 1개만 보유 가능합니다.\n2.재고 소진 시 재입고 후 발송 가능합니다.\n3.발송 시 별도의 안내 예정입니다.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.pinkAccent
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
        )));
  }

  void _onBackTapped() {
    goRouter.pop();
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
  void _openAddressSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DaumPostcodeView(
          onComplete: (model) {
            setState(() {
              // _addressController.text = '${model.zonecode} ${model.address} ${model.buildingName}';
              _addressController.text = '${model.address} ${model.buildingName}';
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> sendRequest(BuildContext ctx) async {
    final String address = '${_addressController.text} ${_address2Controller.text}';
    Map<String, dynamic> body = {
      "state" : widget.state,
      "draft_election_name" : widget.election,
      "draft_district_id": districts,
      "delivery_address": address
    };
    debugPrint('sendRequest_body:$body');
    final response = await _apiService.postItemWithResponse(endpoint: 'drafts/mid-list', body: body);
    debugPrint('sendRequest_response:${response.data}');
    if(response.data['result'] == true && context.mounted) {
      final name = branchManagerProfileData['me']['name'];
      final phone = branchManagerProfileData['me']['phone'];
      showDialog(
        context: ctx,
        builder: (ctx) => CustomAlertDialog(
          dialogInfo: {
            'dialogType': DialogType.success,
            'title': '파라솔 신청',
            'message': '파라솔 신청을 완료하였습니다.',
            'buttonInfo': [
              {
                'btnTitle': '닫기',
                'onPressed': () => ctx.push('/organization/manager/complete?name=$name&phone=$phone&address=$address')
              }
            ]
          },
        ),
      );
    }
  }
}

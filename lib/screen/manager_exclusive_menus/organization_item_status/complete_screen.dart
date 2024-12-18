import 'package:flutter/material.dart';

import '../../../service/app_router.dart';

class CompleteScreen extends StatelessWidget {
  final String clientName;
  final String clientPhone;
  final String clientAddress;

  const CompleteScreen(
      {super.key,
      required this.clientName,
      required this.clientPhone,
      required this.clientAddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '파라솔 신청이 완료되었습니다\n\n감사합니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700
                    ),
                  ),
                  SizedBox(height: 40,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 60,
                    child: Text(
                      '배송정보',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:24.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Colors.black,
                              width: 1.0
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                             '1.이름: $clientName\n2.연락처: $clientPhone\n3.주소: $clientAddress',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                      onPressed: () => {goRouter.go('/')},
                      style: ElevatedButton.styleFrom(
                          backgroundColor:Color(0xff0baf00),
                          foregroundColor: Colors.white,
                          elevation:1,
                          minimumSize: Size(
                             300,
                              50
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      child: Text(
                        '홈으로 이동',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                        ),
                      )
                  ),
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
      ),
    );
  }

  void _onBackTapped() {
    goRouter.pop();
  }
}

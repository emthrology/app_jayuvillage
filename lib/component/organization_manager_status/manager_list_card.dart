import 'package:flutter/material.dart';
import 'package:webview_ex/component/organization_manager_status/phone_button.dart';

class ManagerListCard extends StatelessWidget {
  final Map<String, dynamic> listItem;
  final VoidCallback onTap;
  const ManagerListCard({super.key, required this.listItem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Color(0xff0baf00),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          (listItem['supervisors'] == null ? 0 : listItem['supervisors'].length) >= 12 ? '완성' : '미완성',
                          style: TextStyle(
                              color: (listItem['supervisors'] == null ? 0 : listItem['supervisors'].length) >= 12 ? Colors.white : Colors.yellow,
                              fontWeight: FontWeight.w900,
                              fontSize: 28)),
                      Text(
                          '${getAlphabetFromNumber(listItem['group_at'])}대표 ${listItem['name']} / 임원 ${(listItem['supervisors'] == null ? 0 : listItem['supervisors'].length)}명',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20)
                      ),
                    ],
                  ),
                  PhoneButton(phoneNumber: listItem['phone'])
                ],
              ),
            )
        )
    );
  }
  String getAlphabetFromNumber(int number) {
    return String.fromCharCode(64 + number);
  }
}

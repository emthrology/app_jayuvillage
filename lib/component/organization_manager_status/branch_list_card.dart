import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_ex/component/organization_manager_status/phone_button.dart';

class BranchListCard extends StatelessWidget {
  final Map<String, dynamic> listItem;

  const BranchListCard({super.key, required this.listItem});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: listItem['count'] <= listItem['managerCount']
            ? Color(0xff0baf00)
            // : Colors.red.shade300
        :Color(0xffE14646),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${listItem['draft_election_name']}',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20)),
                    Text(
                        '${listItem['name']} ${listItem['count']}개 / ${listItem['managerCount']}명',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20))
                  ],
                ),
                PhoneButton(phoneNumber: listItem['phone']),
              ],
            )
        )
    );
  }
}

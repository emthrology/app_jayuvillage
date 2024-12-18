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
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Color(0xff0baf00)
          )
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
                        '${listItem['draft_election_name']} ${listItem['name']}',
                        style: TextStyle(
                            color: Color(0xff0baf00),
                            fontWeight: FontWeight.w600,
                            fontSize: 20)),
                    Text(
                        '파라솔 ${listItem['parasol_count']}개 / 마을${listItem['count']}개',
                        style: TextStyle(
                            color: Color(0xff0baf00),
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

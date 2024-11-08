import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class DistrictListCard extends StatelessWidget {
  final Map<String, dynamic> listItem;

  const DistrictListCard({super.key, required this.listItem});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: listItem['count'] == 0 ? Color(0xffE14646) : Color(0xff0baf00),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${listItem['district']}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 24)),
                Text(
                    '대표: ${listItem['count']}명',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 24))
              ],
            )
        )
    );
  }
}

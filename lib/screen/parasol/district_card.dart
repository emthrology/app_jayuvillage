import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:url_launcher/url_launcher.dart';

class DistrictListCard extends StatelessWidget {
  final Map<String, dynamic> listItem;

  const DistrictListCard({super.key, required this.listItem});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Card(
            margin: EdgeInsets.all(12),
              color: listItem['count'] == 0 ? Color(0xffE14646) : Color(0xff0baf00),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          ),
        ),
        Positioned(
          left: 0,  // 왼쪽으로 살짝 겹치게
          top: -110,
          bottom: 0,
          child: Center(
            child: DecoratedIcon(
              icon: Icon(
                Icons.check_outlined,
                color: Color(0xff0baf00),
                size: 48,
              ),
              decoration: IconDecoration(
                border: IconBorder(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            )
          ),
        ),
      ],
    );
  }
}

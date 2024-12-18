import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:url_launcher/url_launcher.dart';

class DistrictListCard extends StatelessWidget {
  final Map<String, dynamic> listItem;
  final bool editable;
  const DistrictListCard({super.key, required this.listItem, required this.editable});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Card(
              margin: EdgeInsets.all(12),
              color: editable == false ?
                listItem['parasol_count'] == 0 ? Colors.white : Color(0xff0abf00):
                  listItem['selected'] == true ? Color(0xff0baf00) :
                    listItem['parasol_count'] == 0 ? Colors.white : Color(0xff0abf00),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                    color:editable == false ?
                    listItem['parasol_count'] == 0 ? Colors.grey.shade300 : Colors.white:
                    listItem['selected'] == true ? Colors.white :
                    listItem['parasol_count'] == 0 ? Color(0xff0abf00) : Colors.white,
                  width: 1.0
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${listItem['district']}',
                      style: TextStyle(
                          color:editable == false ?
                          listItem['parasol_count'] == 0 ? Colors.grey.shade300 : Colors.white:
                          listItem['selected'] == true ? Colors.white :
                          listItem['parasol_count'] == 0 ? Color(0xff0abf00) : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 24)),
                  // Text('파라솔: ${listItem['parasol_count']}개',
                  //     style: TextStyle(
                  //         color:editable == false ?
                  //         listItem['parasol_count'] == 0 ? Colors.grey.shade300 : Colors.white:
                  //         listItem['selected'] == true ? Colors.white :
                  //         listItem['parasol_count'] == 0 ? Color(0xff0abf00) : Colors.white,
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 24))
                ],
              )),
        ),
        if (listItem['parasol_count'] > 0)
          Positioned(
            left: 0, // 왼쪽으로 살짝 겹치게
            top: -60,
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
            )),
          ),
      ],
    );
  }
}

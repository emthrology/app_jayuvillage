import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneButton extends StatelessWidget {
  final String phoneNumber;

  const PhoneButton({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 91,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Color(0xff0baf00))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: GestureDetector(
          onTap: () {
            debugPrint('tel:$phoneNumber');
            if (Platform.isAndroid) {
              _launchURL('tel:$phoneNumber');
            } else if (Platform.isIOS) {
              makeSupportCall('tel:$phoneNumber');
            }
          },
          child: Row(
            children: [
              Icon(
                Icons.phone,
                color: Color(0xff0baf00),
                size: 32,
              ),
              Text(
                '전화',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    color: Color(0xff0baf00),
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
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

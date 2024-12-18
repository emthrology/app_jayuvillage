import 'package:flutter/material.dart';

import '../const/dialog_colors.dart';
import '../const/dialog_type.dart';

class CustomAlertDialog extends StatefulWidget {
  final Map<String, dynamic> dialogInfo;

  const CustomAlertDialog({super.key, required this.dialogInfo});

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  late DialogType dialogType;
  late String title;
  late String message;
  late DialogColors dialogColors;
  late List<dynamic> buttonInfo;

  @override
  void initState() {
    super.initState();
    setDialogSettings();
  }

  void setDialogSettings() {
    var props = widget.dialogInfo;
    if (props['dialogType'] == DialogType.error) {
      dialogColors = ERROR_DIALOG_COLORS;
    } else if (props['dialogType'] == DialogType.success) {
      dialogColors = SUCCESS_DIALOG_COLORS;
    }
    title = props['title'];
    message = props['message'];
    dialogType = props['dialogType'];
    buttonInfo = props['buttonInfo'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Color(dialogColors.color)),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // '비밀번호가 틀렸습니다.\n다시 시도하세요.',
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 20.0),
      // 상단 패딩 조절
      actionsPadding: EdgeInsets.zero,
      // actions의 패딩 제거
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            buttonInfo.length,
                (index) => Expanded(
              // width: double.infinity / buttonInfo.length, // 원하는 너비 설정
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonInfo[index]['btnColor'] ??
                      dialogColors.backgroundColor, // 버튼 배경색
                  shape: RoundedRectangleBorder(
                    borderRadius: index == 0
                        ? BorderRadius.only(bottomLeft: Radius.circular(15))
                        : index == buttonInfo.length - 1
                        ? BorderRadius.only(
                        bottomRight: Radius.circular(15))
                        : buttonInfo.length == 1
                        ? BorderRadius.vertical(
                        bottom: Radius.circular(15))
                        : BorderRadius.zero, // 하단 모서리 둥글게
                  ),
                ),
                onPressed: () {
                  // buttonInfo[0]['onPressed']에 콜백 함수가 있으면 실행
                  if (buttonInfo[index]['onPressed'] != null) {
                    buttonInfo[index]['onPressed'](); // 전달된 콜백 함수 실행
                  } else {
                    Navigator.of(context).pop(); // 기본적으로 창을 닫기
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  // 버튼 높이 조절
                  child: Text(
                    '${buttonInfo[index]['btnTitle']}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: buttonInfo[index]['fontColor'] ??
                            Color(dialogColors.color)), // 텍스트 색상
                  ),
                ),
              ),
            ),
          ),
          // [
          //   SizedBox(
          //     width: double.infinity/buttonInfo.length, // 버튼이 가로로 꽉 차도록 설정
          //     child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: dialogColors.backgroundColor, // 버튼 배경색
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.vertical(
          //               bottom: Radius.circular(15)), // 하단 모서리 둥글게
          //         ),
          //       ),
          //       onPressed: () {
          //         // buttonInfo[0]['onPressed']에 콜백 함수가 있으면 실행
          //         if (buttonInfo[0]['onPressed'] != null) {
          //           buttonInfo[0]['onPressed'](); // 전달된 콜백 함수 실행
          //         } else {
          //           Navigator.of(context).pop(); // 기본적으로 창을 닫기
          //         }
          //       },
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 15.0), // 버튼 높이 조절
          //         child: Text(
          //           '${buttonInfo[0]['btnTitle']}',
          //           style: TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.w600,
          //               color: Color(dialogColors.color)), // 텍스트 색상
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
        )
      ],
    );
  }
}

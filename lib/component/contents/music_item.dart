import 'package:flutter/material.dart';

import '../../page_manager.dart';
import '../../service/dependency_injecter.dart';

class MusicItem extends StatelessWidget {
  MusicItem({super.key, required this.item});
  final _pageManager = getIt<PageManager>();
  final Map<String, dynamic> item;
  final double radius = 10.0;
  final double titleSize = 24.0;
  final double fontSize = 18.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pageManager.addAndPlayItem(item),
      child: Padding(
        padding: const EdgeInsets.only(top:4.0),
        child: Card(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.network(
                item['imageUrl'],
                fit: BoxFit.cover,
                width: 108.0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontSize: titleSize,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                      Text(
                        '${item['album']}·조회수${formatNumber(item['viewCount'])}·공유${formatNumber(item['shareCount'])}',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        item['subtitle'],
                        style: TextStyle(
                          fontSize: fontSize,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  String formatNumber(int number) {
    String numStr = number.toString();
    int length = numStr.length;

    double formattedNumber;
    String unit;

    if (length > 8) {
      formattedNumber = number / 100000000;
      unit = '억';
    } else if (length > 4) {
      formattedNumber = number / 10000;
      unit = '만';
    } else if (length > 3) {
      formattedNumber = number / 1000;
      unit = '천';
    } else {
      return numStr;
    }

    return formattedNumber % 1 == 0
        ? '${formattedNumber.toInt()}$unit'
        : '${formattedNumber.toStringAsFixed(1)}$unit';
  }
}

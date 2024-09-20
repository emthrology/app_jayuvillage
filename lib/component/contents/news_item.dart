import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  const NewsItem({super.key, required this.item});
  final Map<String, dynamic> item;
  final double radius = 10.0;
  final double titleSize = 28.0;
  final double fontSize = 16.0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:4.0),
      child: Card(
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              item['imageUrl'],
              fit: BoxFit.cover,
              width: 84.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: titleSize,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis
                      ),
                    ),

                    Text(
                      '${item['channel']}·조회수${formatNumber(item['viewCount'])}·공유${formatNumber(item['shareCount'])}',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      item['subtitle'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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

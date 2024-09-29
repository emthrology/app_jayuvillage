import 'package:flutter/material.dart';

import '../../service/dependency_injecter.dart';
import '../../service/player_manager.dart';

class NewsItem extends StatelessWidget {
  NewsItem({super.key, required this.item});
  final _pageManager = getIt<PlayerManager>();
  final Map<String, dynamic> item;
  final double radius = 10.0;
  final double titleSize = 24.0;
  final double fontSize = 15.0;
  final double contentsSize = 13.0;
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
              Padding(
                padding: const EdgeInsets.only(left:4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    item['imageUrl'],
                    fit: BoxFit.contain,
                    width: 96.0,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'asset/images/default_thumbnail.png',
                        width: 96.0,
                      );
                    },
                  ),
                ),
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
                            fontFamily: 'NotoSans',
                            fontSize: titleSize,
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            overflow: TextOverflow.ellipsis
                        ),
                      ),

                      Text(
                        '조회수${formatNumber(item['viewCount'])} 공유${formatNumber(item['shareCount'])}',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        item['subtitle'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: contentsSize,
                            height: 0.9
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

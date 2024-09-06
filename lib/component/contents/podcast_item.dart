import 'package:flutter/material.dart';

class PodcastItem extends StatelessWidget {
  const PodcastItem({super.key, required this.item});
  final Map<String, dynamic> item;
  final double radius = 10.0;
  final double titleSize = 18.0;
  final double fontSize = 16.0;
  @override
  Widget build(BuildContext context) {
    bool isLive = item['isLive'] ?? false; // Ensure isLive is not null
    return Padding(
      padding: const EdgeInsets.only(top:4.0),
      child: Card(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              item['imageUrl'],
              fit: BoxFit.cover,
              width: 96.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLive ? '방송중 ${item['title']}' : item['title'],
                    style: TextStyle(
                      fontSize: titleSize,
                      color: isLive ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLive)
                    Row(
                      children: [
                        Text(
                          '${item['listerCount']}명 참여 중',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.green,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:2.0),
                          child: Text(
                            '${item['startTime']} ~ ${item['endTime'] ?? ''}',
                            style: TextStyle(
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (!isLive)
                    Text(
                      '${item['startTime']} ~ ${item['endTime'] ?? ''}',
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  Text(
                    item['subtitle'],
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

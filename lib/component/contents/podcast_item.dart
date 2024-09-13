import 'package:flutter/material.dart';

import '../../service/player_manager.dart';
import '../../service/dependency_injecter.dart';

class PodcastItem extends StatelessWidget {
  PodcastItem({super.key, required this.item});
  final Map<String, dynamic> item;
  final _pageManager = getIt<PlayerManager>();
  final double radius = 10.0;
  final double titleSize = 24.0;
  final double fontSize = 18.0;
  @override
  Widget build(BuildContext context) {
    bool isLive = item['isLive'] ?? false; // Ensure isLive is not null
    return GestureDetector(
      onTap: () => _pageManager.addAndPlayItem(item),
      child: Padding(
        padding: const EdgeInsets.only(top:4.0),
        child: Card(
          color: Colors.white,
          shadowColor: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Image.network(
                    item['imageUrl'],
                    fit: BoxFit.cover,
                    width: 84.0,
                  ),
                  if(isLive)
                    Container(
                      padding: const EdgeInsets.only(top:8.0),
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'asset/images/onair.png',
                        fit: BoxFit.cover,
                        width: 72.0
                      ),
                    )
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        children: [
                          if(isLive)
                            Padding(
                              padding: const EdgeInsets.only(right:4.0),
                              child: Text(
                                '방송중',
                                style: TextStyle(
                                  fontSize: titleSize,
                                  color:Colors.red,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis
                                ),
                              ),
                            ),
                          Text(
                            item['title'],
                            style: TextStyle(
                                fontSize: titleSize,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
      ),
    );
  }
}

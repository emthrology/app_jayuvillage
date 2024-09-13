import 'package:flutter/material.dart';

import '../../screen/contents/video_screen.dart';

class VideoItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const VideoItem({super.key, required this.item,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => VideoScreen(item:item))
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top:4.0),
        child: Column(
          children:[
            Card(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 추가: 자식들의 높이에 맞게 조정
              children: [
                // Image.network(
                //   'https://example.com/image.jpg',
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0)
                  ),
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: Image.network(
                      item['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text('광화문레코드 · 조회수 2.7억 · 공유 3.7만', style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700
                          ),),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.favorite_border),
                label: Text('좋아요 1'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.share),
                label: Text('공유하기'),
              ),
            ],
          ),
          ]
        ),
      ),
    );
  }
}

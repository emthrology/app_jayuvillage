import 'package:flutter/material.dart';

class EventListCard extends StatefulWidget {
  final Map<String, dynamic> cardData;

  const EventListCard({super.key, required this.cardData});

  @override
  State<EventListCard> createState() => _EventListCardState();
}

class _EventListCardState extends State<EventListCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:16.0, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${widget.cardData['position']}',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Text('관리대상 ${widget.cardData['manage']['total']}명',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600
                  ),
                ),
                Text('전체 ${widget.cardData['total']['total']}명',
                  style: TextStyle(
                      fontSize: 24
                  ),
                ),
              ],
            ),
            // 접속 및 미접속 정보
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('접속', style: TextStyle(fontSize: 22)),
                      Text('${widget.cardData['manage']['connected']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 36, height: 1.1,)),
                      Text('${widget.cardData['total']['connected']}',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold, fontSize: 36, height: 1.1,)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('미접속',
                          style: TextStyle(fontSize: 22, color: Colors.red)),
                      Text('${widget.cardData['manage']['disconnected']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                              height: 1.1,
                              color: Colors.red)),
                      Text('${widget.cardData['total']['disconnected']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                              height: 1.1,
                              color: Colors.red[200])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

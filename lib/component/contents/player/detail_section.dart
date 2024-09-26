import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class DetailSection extends StatefulWidget {
  final MediaItem mediaItem;

  const DetailSection({super.key, required this.mediaItem});

  @override
  _DetailSectionState createState() => _DetailSectionState();
}

class _DetailSectionState extends State<DetailSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.mediaItem.title,
            maxLines: 5,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Text(
                widget.mediaItem.album ?? '',
                maxLines: 2,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text('·'),
              Text(
                widget.mediaItem.extras?['author'] ?? '',
                maxLines: 2,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    widget.mediaItem.extras?['subtitle'] ?? '',
                    maxLines: _isExpanded ? null : 3,
                    overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'NotoSans',
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 1,
                  child: Text(
                    _isExpanded ? '간략히' :'..더보기',
                    style: TextStyle(
                      color: Color(0xFF0BAF00),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
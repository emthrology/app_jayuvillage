import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../../../const/contents/content_type.dart';
import '../../shaped_icon_button.dart';

class MiniListItem extends StatelessWidget {
  const MiniListItem(
      {super.key, required this.mediaItem,});

  final MediaItem mediaItem;


  final double _radius = 10.0;
  final double _titleSize = 24.0;
  final double _fontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Container(
        height: 75,
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (mediaItem.artUri == null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      'asset/images/default_thumbnail.png',
                      fit: BoxFit.cover,
                      width: 40.0,
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      mediaItem.artUri.toString(),
                      fit: BoxFit.cover,
                      width: 40.0,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mediaItem.title,
                          style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: _titleSize,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
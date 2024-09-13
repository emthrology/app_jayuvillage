import 'package:flutter/material.dart';
import '../../const/contents/content_type.dart';
import '../shaped_icon_button.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.isEditMode,
    required this.item,
    this.onMoveUp,
    this.onMoveDown,
    this.onDelete
  });

  final Map<String, dynamic> item;
  final bool isEditMode;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onDelete;

  final double _radius = 10.0;
  final double _titleSize = 24.0;
  final double _fontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              item['imageUrl'] == null
                  ? Image.asset(
                      'asset/images/default_thumbnail.png',
                      fit: BoxFit.cover,
                      width: 96.0,
                    )
                  : Image.network(
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
                        style: TextStyle(
                            fontSize: _titleSize,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        _getContentTypeLabel(item),
                        style: TextStyle(
                          fontSize: _fontSize,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
              if (isEditMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShapedIconButton(
                      width: 32,
                      icon: Icon(Icons.arrow_upward_sharp, size: 20.0),
                      onPressed: onMoveUp,
                    ),
                    SizedBox(width: 4),
                    ShapedIconButton(
                      width: 32,
                      icon: Icon(Icons.arrow_downward_sharp, size: 20.0),
                      onPressed: onMoveDown,
                    ),
                    SizedBox(width: 4),
                    ShapedIconButton(
                      width: 32,
                      icon: Icon(Icons.delete_outline_outlined, size: 20.0),
                      onPressed: onDelete,
                    ),
                  ],
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

  String _getContentTypeLabel(Map<String, dynamic> item) {
    switch (item['type']) {
      case ContentType.video:
        return '비디오';
      case ContentType.podcast:
        return '팟캐스트';
      case ContentType.music:
        return '음악';
      case ContentType.news:
        return '뉴스';
      default:
        return '';
    }
  }


}

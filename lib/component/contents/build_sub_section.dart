import 'package:flutter/material.dart';
import 'package:webview_ex/component/contents/music_item.dart';
import 'package:webview_ex/const/contents/content_type.dart';

import '../../screen/contents/type_selected_contents_screen.dart';
import '../../service/contents/mapping_service.dart';
import '../white_button.dart';
class BuildSubSection extends StatelessWidget {
  final Map<dynamic, dynamic> subList;
  const BuildSubSection({super.key, required this.subList});

  @override
  Widget build(BuildContext context) {
    String title = subList.keys.first;
    List<dynamic> items = subList.values.first;
    final MappingService mappingService = MappingService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        ...mappingService.mapItems(items, ContentType.music).map((item) => MusicItem(item: item)),
        SizedBox(height: 10,),
        if (subList.values.toList().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
                child: WhiteButton(
                  size: Size(MediaQuery.of(context).size.width - 100, 50),
                  onTap: () {
                    onTapMore(context, ContentType.music, title);
                  },
                  title: '$title 더보기',
                )),
          ),
        SizedBox(height: 32), //
      ],
    );
  }
  void onTapMore(BuildContext context, ContentType type, String title) {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (_) => TypeSelectedContentsScreen(contentType: type)));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TypeSelectedContentsScreen(contentType: type, subtitle: title)));
  }
}

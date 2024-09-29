import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import './mini_list_item.dart';
import '../../../service/dependency_injecter.dart';
import '../../../service/player_manager.dart';

class PlayerPlaylistModal extends StatefulWidget {
  const PlayerPlaylistModal({super.key});

  @override
  State<PlayerPlaylistModal> createState() => _PlayerPlaylistModalState();
}

class _PlayerPlaylistModalState extends State<PlayerPlaylistModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  final playerManager = getIt<PlayerManager>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        padding: const EdgeInsets.only(top: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('닫기',
                        style: TextStyle(fontSize: 18.0, color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('완료',
                        style: TextStyle(fontSize: 18.0, color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height *0.9 - 180,
                child: ValueListenableBuilder<List<MediaItem>>(
                  valueListenable: playerManager.playlistNotifier,
                  builder: (context, playlistTitles, _) {
                    return ListView.builder(
                      itemCount: playlistTitles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: MiniListItem(mediaItem: playlistTitles[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              _showOptions(context, index);
                            },
                          ),
                          onTap: () => playerManager.skipToQueueItem(index),
                          selected: playlistTitles[index].title ==
                              playerManager.currentSongTitleNotifier.value,
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ListTile(
            //   leading: Icon(Icons.add),
            //   title: Text('보관함에 추가'),
            //   onTap: () {},
            // ),
            ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('바로 재생'),
              onTap: () =>{
                playerManager.skipToQueueItem(index),
                Navigator.pop(context)
              }
            ),
            ListTile(
              leading: Icon(Icons.remove),
              title: Text('재생목록에서 제거'),
              onTap: () => {playerManager.removeAt(index),
                Navigator.pop(context)
              }
            ),
            SizedBox(height: 10.0,)
          ],
        );
      },
    );
  }
}

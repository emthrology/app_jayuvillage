import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';

import '../../component/contents/storage/list_playlist_modal.dart';
import '../../service/api_service.dart';
import '../../service/dependency_injecter.dart';
import '../../service/player_manager.dart';
import '../../notifiers/play_button_notifier.dart';
import '../../notifiers/progress_notifier.dart';
import '../../notifiers/repeat_button_notifier.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

final playerManager = getIt<PlayerManager>();

class _AudioScreenState extends State<AudioScreen> {
  late AudioPlayer player;
  final ApiService _apiService = ApiService();
  // bool _isLoading = true;
  List<dynamic> bags = [];
  String currentTitle = '';
  final mediaItem = playerManager.getCurrentMediaItem();

  Future<void> _loadBags() async {
    try {
      final bagsData = await _apiService.fetchItems(
        endpoint: 'bagitems',
      );
      setState(() {
        bags = bagsData;

      });
    } catch (e) {
      print('Error loading bags: $e');
    } finally {
    }
  }
  @override
  void initState() {
    super.initState();
    _loadBags();
    // getIt<PageManager>().init();
  }

  @override
  void dispose() {
    // pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Stack(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 36.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: ValueListenableBuilder<String>(
                        valueListenable: playerManager.currentSongArtUriNotifier,
                        builder: (_, artUri, __) {
                          return artUri.isNotEmpty
                              ? Padding(
                                padding: const EdgeInsets.symmetric(vertical:32.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                      maxHeight: MediaQuery.of(context).size.height * 0.75,
                                  ),
                                  child: Image.network(
                                    artUri,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'asset/images/default_thumbnail.png',
                                        width:
                                            MediaQuery.of(context).size.width ,
                                      );
                                    },
                                  ),
                                ),
                              )
                              : Image.asset(
                                'asset/images/default_thumbnail.png',
                                width: MediaQuery.of(context).size.width,
                              );
                        },
                      ),
                    ),
                    CurrentSongTitle(),
                    // AddRemoveSongButtons(),
                    AudioProgressBar(),
                    AudioControlButtons(),
                    SocialButtons(bags:bags),
                    Playlist(),

                  ],
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Semantics(
                    label: '뒤로가기',
                    hint: '이전 화면으로 가기 위해 누르세요',
                    child: GestureDetector(
                      onTap: _onTapped,
                      child: Row(children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 32.0,
                        ),
                      ]),
                    ),
                  )
                ],
              ),
            ),
          ],
        )));
  }

  void _onTapped() {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (_) => ContentsIndexScreen()
    // ));
    Navigator.of(context).pop(); //
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: playerManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 28)),
              ],
            ));
      },
    );
  }
}

class Playlist extends StatelessWidget {
  const Playlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: playerManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(playlistTitles[index]),
                onTap: () => playerManager.skipToQueueItem(index),
                selected: index == playerManager.currentSongTitleNotifier.value,
              );
            },
          );
        },
      ),
    );
  }
}

class AddRemoveSongButtons extends StatelessWidget {
  const AddRemoveSongButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: playerManager.add,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: playerManager.remove,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: playerManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: playerManager.seek,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RepeatButton(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class SocialButtons extends StatefulWidget {
  final List<dynamic> bags;
  SocialButtons({super.key, required this.bags});

  @override
  State<SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconText(Icons.favorite_border, '좋아요 32', () {
            print('좋아요 클릭됨');
          }),
          // _buildIconText(Icons.comment, '댓글 5', () {
          //   print('댓글 클릭됨');
          // }),
          _buildIconText(Icons.library_music_rounded, '보관함', () {
            addToPlaylist(context, widget.bags);
          }),
          _buildIconText(Icons.share, '공유', () {
            print('공유 클릭됨');
          }),
        ],
      ),
    );
  }

  void addToPlaylist(BuildContext context, List<dynamic>bags) {
    final mediaItem = playerManager.getCurrentMediaItem();
    // print('mediaItem:$mediaItem');
    if(mediaItem == null) {
      Fluttertoast.showToast(
          msg: "곡 정보가 없습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Color(0xffff0000),
          textColor: Colors.white,
          fontSize: 24.0,
      );
      return;
    }
    // print('mediaItem.id:${mediaItem!.id}');
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => ListPlaylistModal(
        playlists: bags,
        audio_id: mediaItem.id
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RepeatState>(
      valueListenable: playerManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = const Icon(Icons.repeat, color: Colors.grey);
            break;
          case RepeatState.repeatSong:
            icon = const Icon(Icons.repeat_one);
            break;
          case RepeatState.repeatPlaylist:
            icon = const Icon(Icons.repeat);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: playerManager.repeat,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playerManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: (isFirst) ? null : playerManager.previous,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: playerManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: playerManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: playerManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playerManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (isLast) ? null : playerManager.next,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playerManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled)
              ? const Icon(Icons.shuffle)
              : const Icon(Icons.shuffle, color: Colors.grey),
          onPressed: playerManager.shuffle,
        );
      },
    );
  }
}

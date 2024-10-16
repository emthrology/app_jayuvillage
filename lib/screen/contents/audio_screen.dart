import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:webview_ex/component/comments_section.dart';
import 'package:webview_ex/const/contents/content_type.dart';
import 'package:webview_ex/service/contents/mapping_service.dart';

import '../../component/contents/player/detail_section.dart';
import '../../component/contents/player/social_buttons.dart';
import '../../component/contents/storage/list_playlist_modal.dart';
import '../../service/api_service.dart';
import '../../service/dependency_injecter.dart';
import '../../service/player_manager.dart';
import '../../notifiers/play_button_notifier.dart';
import '../../notifiers/progress_notifier.dart';
import '../../notifiers/repeat_button_notifier.dart';
import '../../store/secure_storage.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

final playerManager = getIt<PlayerManager>();

class _AudioScreenState extends State<AudioScreen> {
  late AudioPlayer player;
  final MappingService _mappingService = MappingService();
  final ApiService _apiService = ApiService();
  final secureStorage = getIt<SecureStorage>();
  // bool _isLoading = true;
  List<dynamic> bags = [];
  String currentTitle = '';

  final mediaItem = playerManager.currentMediaItemNotifier.value;

  Future<dynamic> getValue(key) async {
    String value = await secureStorage.readSecureData(key);
    return value;
  }

  Future<void> _loadBags() async {
    try {
      String sessionData = await getValue('session');
      Map<String, dynamic> json = jsonDecode(sessionData);
      int user_id = json['success']?['id'];
      final bagsData = await _apiService.fetchItems(
        endpoint: 'bagitems',
        queries: {'user_id':'$user_id'}
      );
      setState(() {
        bags = bagsData;
      });
    } catch (e) {
      print('Error loading bags: $e');
    } finally {}
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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: SingleChildScrollView(
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
                          valueListenable:
                              playerManager.currentSongArtUriNotifier,
                          builder: (_, artUri, __) {
                            return artUri.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 32.0),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.75,
                                      ),
                                      child: Image.network(
                                        artUri,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'asset/images/default_thumbnail.png',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                      SocialButtons(bags: bags, mediaItem: mediaItem!, contentType:_mappingService.getEnumFromString(mediaItem!.extras?['type'], ContentType.values)!),
                      ValueListenableBuilder<MediaItem?>(
                        valueListenable: playerManager.currentMediaItemNotifier,
                        builder: (_, mediaItem, __) {
                          return mediaItem != null
                              ? DetailSection(mediaItem: mediaItem)
                              : SizedBox.shrink();
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CommentsSection(contentType:_mappingService.getEnumFromString(mediaItem!.extras?['type'], ContentType.values)!, commentableId: mediaItem!.id,),
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
          ),
        )));
  }

  void _onTapped() {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (_) => ContentsIndexScreen()
    // ));
    context.pop();
    // Navigator.of(context).pop(); //
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
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 28, overflow: TextOverflow.ellipsis)),
                  ),
                ),
              ],
            ));
      },
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
    return ValueListenableBuilder<bool>(
      valueListenable: playerManager.isLiveStreamNotifier,
      builder: (_, isLiveStream, __) {
        if (isLiveStream) {
          return Center(
            child: Text(
              '라이브 방송 중',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
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

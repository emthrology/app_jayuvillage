import 'package:youtube_explode_dart/youtube_explode_dart.dart';
class YoutubeAudioUrlExtractor {
  Future<String> getAudioUrl(String videoId) async {
    final yt = YoutubeExplode();
    final manifest = await yt.videos.streamsClient.getManifest(videoId);
    final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
    final audioUrl = audioStreamInfo.url.toString();
    print('audioUrl:${audioUrl}');
    return audioUrl;
  }
}
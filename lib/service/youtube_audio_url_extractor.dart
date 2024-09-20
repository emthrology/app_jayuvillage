import 'package:youtube_explode_dart/youtube_explode_dart.dart';
class YoutubeAudioUrlExtractor {
  Future<String> getAudioUrl(String youtubeUrl) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(youtubeUrl);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);
      final audioOnlyStreams = manifest.audioOnly;
      final streamInfo = audioOnlyStreams.withHighestBitrate();
      return streamInfo.url.toString();
    } finally {
      yt.close();
    }
  }
}
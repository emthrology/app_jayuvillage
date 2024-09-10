
import 'package:audio_service/audio_service.dart';

import '../page_manager.dart';
import 'audio_handler.dart';
import 'playlist_repository.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<AudioHandler>(await initAudioService());

  // services
  getIt.registerLazySingleton<PlaylistRepository>(() => Playlist());

  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());

}

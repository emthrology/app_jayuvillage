
import 'package:audio_service/audio_service.dart';
import 'package:webview_ex/store/store_service.dart';

import '../store/secure_storage.dart';
import 'player_manager.dart';
import 'audio_handler.dart';
import 'playlist_repository.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<AudioHandler>(await initAudioService());

  // services
  getIt.registerLazySingleton<PlaylistRepository>(() => Playlist());

  // page state
  getIt.registerLazySingleton<PlayerManager>(() => PlayerManager());

  // store state
  getIt.registerLazySingleton<StoreService>(() => StoreService());

  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());

}

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'theme/theme_manager.dart';
import 'services/user_state.dart';
import 'services/audio_player_handler.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.hczmusic.player.channel.audio',
      androidNotificationChannelName: 'HczMusic Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  
  runApp(HczMusicApp(audioHandler: audioHandler));
}

class HczMusicApp extends StatelessWidget {
  final AudioHandler audioHandler;

  const HczMusicApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: audioHandler as AudioPlayerHandler),
        ChangeNotifierProvider(create: (context) => ThemeManager()),
        ChangeNotifierProvider(create: (context) => UserState()),
      ],
      child: Consumer3<AudioPlayerHandler, ThemeManager, UserState>(
        builder: (context, audioHandler, themeManager, userState, child) {
          return MaterialApp(
            title: 'HczMusic',
            theme: ThemeManager.lightTheme(),
            darkTheme: ThemeManager.darkTheme(),
            themeMode: themeManager.themeMode,
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

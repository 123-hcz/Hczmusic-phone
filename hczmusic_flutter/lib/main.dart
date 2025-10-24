import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_manager.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const HczMusicApp());
}

class HczMusicApp extends StatelessWidget {
  const HczMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
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

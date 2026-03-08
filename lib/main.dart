import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/theme/theme_notifier.dart';
import 'package:video_downloader/screens/splash_screen.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';

final ThemeNotifier themeNotifier = ThemeNotifier();

void main() {
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: subscriptionNotifier,
          builder: (context, _) {
            return MaterialApp(
              title: 'InstaVibe',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeNotifier.themeMode,
              home: const SplashScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}

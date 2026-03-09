import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/screens/splash_screen.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: subscriptionNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'ClipCatch',
          theme: AppTheme.darkTheme,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

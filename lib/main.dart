import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/screens/splash_screen.dart';
import 'package:video_downloader/services/notification_service.dart';
import 'package:video_downloader/services/ad_service.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';
import 'package:video_downloader/theme/theme_notifier.dart';
import 'package:video_downloader/services/iap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services in background without blocking UI
  NotificationService().init();
  AdService().init();
  IAPService().init();
  
  await themeNotifier.load();
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([subscriptionNotifier, themeNotifier]),
      builder: (context, _) {
        return MaterialApp(
          title: 'ClipCatch',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          themeAnimationDuration: Duration.zero,
          themeAnimationCurve: Curves.easeOut,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

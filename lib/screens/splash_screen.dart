import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_downloader/screens/main_screen.dart';
import 'package:video_downloader/services/ad_service.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  bool _isAdDismissed = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _controller.forward();

    _loadInterstitialAd();

    // Give the splash screen at least 3 seconds, but check for ad
    Future.delayed(const Duration(milliseconds: 3000), () {
      _checkAndNavigate();
    });
  }

  void _loadInterstitialAd() {
    if (subscriptionNotifier.isPro) return;
    
    if (mounted) {
      setState(() {
        _isAdLoading = true;
      });
    }
    debugPrint('Splash: Loading Interstitial Ad...');

    InterstitialAd.load(
      adUnitId: AdService().interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Splash: Interstitial Ad LOADED');
          _interstitialAd = ad;
          if (mounted) {
            setState(() {
              _isAdLoading = false;
            });
          }
        },
        onAdFailedToLoad: (err) {
          debugPrint('Splash: Interstitial Ad FAILED to load: $err');
          _interstitialAd = null;
          if (mounted) {
            setState(() {
              _isAdLoading = false;
            });
          }
        },
      ),
    );
  }

  Future<void> _checkAndNavigate() async {
    if (!mounted || _isAdDismissed) return;

    // If ad is still loading, wait up to 5 more seconds (total 8s max from start)
    int waitCount = 0;
    while (_isAdLoading && waitCount < 10) {
      debugPrint('Splash: Still loading ad... waiting 500ms (Try $waitCount/10)');
      await Future.delayed(const Duration(milliseconds: 500));
      waitCount++;
    }

    _navigateToMain();
  }

  void _navigateToMain() {
    if (!mounted || _isAdDismissed) return;

    if (_interstitialAd != null && !subscriptionNotifier.isPro) {
      debugPrint('Splash: Attempting to show Interstitial Ad');
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Splash: Ad Dismissed by user');
          ad.dispose();
          _isAdDismissed = true;
          _proceedToMain();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          debugPrint('Splash: Ad Failed to show: $err');
          ad.dispose();
          _isAdDismissed = true;
          _proceedToMain();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('Splash: No ad available (isPro: ${subscriptionNotifier.isPro}, adNull: ${_interstitialAd == null}), skip to main');
      _proceedToMain();
    }
  }

  void _proceedToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppTheme.surfaceFor(brightness),
              AppTheme.backgroundFor(brightness),
            ],
            radius: 1.5,
            center: Alignment.center,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = _scaleAnimation.value * 1.05; // Slightly larger pop
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity01(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(52),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity01(0.3),
                            blurRadius: 40,
                            spreadRadius: 5,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded, 
                        size: 80, 
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'ClipCatch',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textFor(brightness),
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Premium Video Downloader'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                      ),
                      if (_isAdLoading) ...[
                        const SizedBox(height: 32),
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

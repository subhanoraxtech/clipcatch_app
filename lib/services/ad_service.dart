import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const String testBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String testBannerIdIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const String testInterstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String testInterstitialIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  String get bannerAdUnitId {
    // ALWAYS return test IDs as requested by user to prevent invalid traffic during dev
    return Platform.isAndroid ? testBannerIdAndroid : testBannerIdIOS;
  }

  String get interstitialAdUnitId {
    // ALWAYS return test IDs as requested by user to prevent invalid traffic during dev
    return Platform.isAndroid ? testInterstitialIdAndroid : testInterstitialIdIOS;
  }
}

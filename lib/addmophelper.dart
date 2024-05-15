import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobHelper {
  static InterstitialAd? _interstitialAd;

  static initialization() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  static createInterAdd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? "ca-app-pub-3268483485980318/6482328548"
            : "ca-app-pub-3268483485980318/7968237437",
        request: const AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');

          _interstitialAd = null;
          createInterAdd();
        }));
  }

  static showInterAdd() {
    print("showInterAdd was initialized");
    if (_interstitialAd == null) {
      print("_interstitialAd was null");
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print("fuull screen add shown");
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print("add dispoded");
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError adError) {
        print('$ad onadd failed $adError');
        ad.dispose();
        createInterAdd();
      },
      onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
    );
    _interstitialAd!.show();
    // _interstitialAd = null;
  }
}

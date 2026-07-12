// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_milestone/utils/clarityService.dart';

/// Handles App Open ads and listens for app-resume lifecycle events.
/// Call [init] once at startup and [dispose] when the app exits.
class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  static const String _adUnitId =
      'ca-app-pub-6830153046105033/4393957993';

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _hasShownOnce = false; // show at most once per app session
  DateTime? _loadTime;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _loadAd();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
  }

  void _loadAd() {
    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('AppOpenAd loaded');
          _appOpenAd = ad;
          _loadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          _appOpenAd = null;
        },
      ),
    );
  }

  // App Open ads expire after 4 hours.
  bool get _isAdValid {
    if (_appOpenAd == null || _loadTime == null) return false;
    return DateTime.now().difference(_loadTime!).inHours < 4;
  }

  /// Returns true if the ad was triggered, false if blocked (already shown / not ready).
  bool showAdIfAvailable() {
    // Only show once per process lifetime — repeated backgrounding must not retrigger.
    if (_hasShownOnce || !_isAdValid || _isShowingAd) {
      return false;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _isShowingAd = true;
        _hasShownOnce = true;
        ClarityService.logAppOpenAdShown();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('AppOpenAd failed to show: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
    );
    _appOpenAd!.show();
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showAdIfAvailable();
    }
  }
}

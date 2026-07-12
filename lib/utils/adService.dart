// ignore_for_file: avoid_print

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_milestone/utils/clarityService.dart';

/// Singleton that manages interstitial ad loading and display.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static const String _interstitialAdUnitId =
      'ca-app-pub-6830153046105033/5463497080';

  InterstitialAd? _interstitialAd;
  int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  // Minimum gap between any two interstitial shows (3 minutes)
  static const int _cooldownSeconds = 180;
  DateTime? _lastShownAt;

  // Counter used by showInterstitialOnEveryNthTap
  int _tapCount = 0;
  // Separate counter for deposit/withdraw actions
  int _transactionCount = 0;

  void initialize() {
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('InterstitialAd loaded');
          _interstitialAd = ad;
          _loadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
          _loadAttempts++;
          _interstitialAd = null;
          if (_loadAttempts < _maxLoadAttempts) {
            _loadInterstitial();
          }
        },
      ),
    );
  }

  bool get _isCoolingDown {
    if (_lastShownAt == null) return false;
    return DateTime.now().difference(_lastShownAt!).inSeconds < _cooldownSeconds;
  }

  /// Shows an interstitial if one is ready AND the cooldown has elapsed.
  void showInterstitialIfReady() {
    if (_isCoolingDown || _interstitialAd == null) {
      if (_interstitialAd == null) _loadInterstitial();
      return;
    }
    _lastShownAt = DateTime.now();
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('InterstitialAd failed to show: $error');
        ad.dispose();
        _loadInterstitial();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
    ClarityService.logInterstitialAdShown();
  }

  /// Increments internal counter; shows interstitial on every [threshold]-th call.
  void showInterstitialOnEveryNthTap({int threshold = 5}) {
    _tapCount++;
    if (_tapCount >= threshold) {
      _tapCount = 0;
      showInterstitialIfReady();
    }
  }

  /// For deposit/withdraw actions — shows only on every 3rd transaction.
  void showInterstitialOnTransaction() {
    _transactionCount++;
    if (_transactionCount >= 3) {
      _transactionCount = 0;
      showInterstitialIfReady();
    }
  }

  /// After adding a new goal: shows interstitial if ready.
  void showPostGoalAd() {
    showInterstitialIfReady();
  }
}

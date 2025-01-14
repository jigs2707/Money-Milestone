// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  _BannerAdWidget createState() => _BannerAdWidget();
}

class _BannerAdWidget extends State<BannerAdWidget> {
  BannerAd? _googleBannerAd;

  @override
  void initState() {
    super.initState();
    _initBannerAd();
  }

  @override
  void dispose() {
    _googleBannerAd?.dispose();

    super.dispose();
  }

  void _initBannerAd() {
    Future.delayed(Duration.zero, () {
      _createGoogleBannerAd();
    });
  }

  Future<void> _createGoogleBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      request: const AdRequest(),
      adUnitId: 'ca-app-pub-6830153046105033/1225127381',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded');
          setState(() {
            _googleBannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed'),
      ),
      size: size,
    );
    banner.load();
  }

  @override
  Widget build(BuildContext context) {
    return _googleBannerAd != null
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: _googleBannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _googleBannerAd!),
          )
        : const SizedBox.shrink();
  }
}

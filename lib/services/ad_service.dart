import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;

  // IDs de PRUEBA de AdMob
  // Android - TEST IDs
  final String _bannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  final String _interstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  // iOS - TEST IDs
  final String _bannerIdIos = 'ca-app-pub-3940256099942544/2934735716';
  final String _interstitialIdIos = 'ca-app-pub-3940256099942544/4411468910';

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _bannerIdAndroid;
    } else if (Platform.isIOS) {
      return _bannerIdIos;
    }
    throw UnsupportedError("Unsupported platform");
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _interstitialIdAndroid;
    } else if (Platform.isIOS) {
      return _interstitialIdIos;
    }
    throw UnsupportedError("Unsupported platform");
  }

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  BannerAd? getBannerAd() {
    return _isBannerAdReady ? _bannerAd : null;
  }

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadInterstitial(); // Cargar el siguiente
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (err) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void showInterstitial() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
    } else {
      print('Interstitial no listo aún');
      loadInterstitial(); // Intentar cargar de nuevo si falló
    }
  }
  
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}

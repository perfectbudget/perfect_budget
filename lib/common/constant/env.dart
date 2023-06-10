import 'dart:io';
import 'dart:math';

import 'package:applovin_max/applovin_max.dart';

mixin EnvValue {
  /* MUST-CONFIG */
  static const String policy = 'your_policy';
  static const String terms = 'your_term';
  static const String legalInappPurchase =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
  static const String uploadImage = 'https://api.storage.timistudio.dev/upload';
  static const String icDefaultIncome =
      'https://user-images.githubusercontent.com/79369571/203107829-9288c533-74d3-4aaf-8260-a24b7d808a2f.png';
  static const String icDefaultExpense =
      'https://user-images.githubusercontent.com/79369571/203107837-b07642ef-532f-42be-90a5-a338016ca9ca.png';
}

/* MUST-CONFIG */
class AdHelper {
  String keySdkApplovin =
      'KhsPIDVd3MrdPzZWPW72TMlNyz7Slomt8tvTwz5XhWeM7gSRzFpvqh0JmSFpirFLybVfIGfH8UkemHQa7kiLM1';

  String get bannerAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return 'b4227e7ff65fbb5b';
    } else if (Platform.isIOS) {
      return 'b4227e7ff65fbb5b';
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get openAppAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return 'b4227e7ff65fbb5b';
    } else if (Platform.isIOS) {
      return 'b4227e7ff65fbb5b';
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get interstitialAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return 'b4227e7ff65fbb5b';
    } else if (Platform.isIOS) {
      return 'b4227e7ff65fbb5b';
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get rewardAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return 'b4227e7ff65fbb5b';
    } else if (Platform.isIOS) {
      return 'b4227e7ff65fbb5b';
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get mrecAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return 'b4227e7ff65fbb5b';
    } else if (Platform.isIOS) {
      return 'b4227e7ff65fbb5b';
    }
    throw UnsupportedError('Unsupported platform');
  }

  void initializeInterstitialAds(
      {required dynamic Function(MaxAd) onAdDisplayedCallback}) {
    var _interstitialRetryAttempt = 0;
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id) will now return 'true'
        print('Interstitial ad loaded from ' + ad.networkName);

        // Reset retry attempt
        _interstitialRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        _interstitialRetryAttempt = _interstitialRetryAttempt + 1;

        final int retryDelay =
            pow(2, min(6, _interstitialRetryAttempt)).toInt();

        print('Interstitial ad failed to load with code ' +
            error.code.toString() +
            ' - retrying in ' +
            retryDelay.toString() +
            's');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          AppLovinMAX.loadInterstitial(interstitialAdUnitIdApplovin);
        });
      },
      onAdDisplayedCallback: onAdDisplayedCallback,
      onAdDisplayFailedCallback: (ad, error) {},
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {},
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(interstitialAdUnitIdApplovin);
  }

  void initializeRewardedAds(
      {required dynamic Function(MaxAd, MaxReward)
          onAdReceivedRewardCallback}) {
    var _rewardedAdRetryAttempt = 0;
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
        onAdLoadedCallback: (ad) {
          // Rewarded ad is ready to be shown. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) will now return 'true'
          print('Rewarded ad loaded from ' + ad.networkName);

          // Reset retry attempt
          _rewardedAdRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          // Rewarded ad failed to load
          // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
          _rewardedAdRetryAttempt = _rewardedAdRetryAttempt + 1;

          final int retryDelay =
              pow(2, min(6, _rewardedAdRetryAttempt)).toInt();
          print('Rewarded ad failed to load with code ' +
              error.code.toString() +
              ' - retrying in ' +
              retryDelay.toString() +
              's');

          Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
            AppLovinMAX.loadRewardedAd(rewardAdUnitIdApplovin);
          });
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {},
        onAdReceivedRewardCallback: onAdReceivedRewardCallback));
    AppLovinMAX.loadRewardedAd(rewardAdUnitIdApplovin);
  }
}

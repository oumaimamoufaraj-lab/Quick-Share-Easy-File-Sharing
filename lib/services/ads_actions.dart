import 'dart:async';

import 'package:multiads/multiads.dart';

import '../util/global.dart';

/// Registers ad lifecycle callbacks and helpers used across the app.
abstract final class AdsActions {
  static const _loadPollInterval = Duration(milliseconds: 200);
  static const _loadWaitTimeout = Duration(milliseconds: 3000);
  static const _adDismissTimeout = Duration(seconds: 60);

  static void registerCallbacks() {
    AdCallbacks.onInterstitialDismissed = () {
      isInterShowed = false;
    };
  }

  /// Shows a cold-start app open ad after splash, if remote config enables it.
  ///
  /// Waits briefly for a preloaded ad, then proceeds without blocking core flows
  /// when no ad is available.
  static Future<void> showAppOpenIfAvailable() async {
    if (!gAdsReady || gAds == null || appOpenShownThisSession) {
      pastSplash = true;
      return;
    }
    if (!gAds!.hasAppOpen) {
      pastSplash = true;
      return;
    }

    appOpenShownThisSession = true;

    final dismissCompleter = Completer<void>();
    AdCallbacks.onAppOpenDismissed = () {
      pastSplash = true;
      AdCallbacks.onAppOpenDismissed = null;
      if (!dismissCompleter.isCompleted) {
        dismissCompleter.complete();
      }
    };

    final deadline = DateTime.now().add(_loadWaitTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final shown = await gAds!.openAdsInstance.showAdIfAvailableOpenAds();
      if (shown) {
        try {
          await dismissCompleter.future.timeout(_adDismissTimeout);
        } on TimeoutException {
          pastSplash = true;
        }
        return;
      }
      await Future<void>.delayed(_loadPollInterval);
    }

    pastSplash = true;
    AdCallbacks.onAppOpenDismissed = null;
  }

  static void showInterstitial({void Function()? onDismissed}) {
    if (!gAdsReady || gAds == null || !gAds!.hasInterstitials || isInterShowed) {
      onDismissed?.call();
      return;
    }

    isInterShowed = true;
    AdCallbacks.onInterstitialDismissed = () {
      isInterShowed = false;
      AdCallbacks.onInterstitialDismissed = null;
      onDismissed?.call();
    };
    gAds!.interInstance.showInterstitialAd();
  }
}

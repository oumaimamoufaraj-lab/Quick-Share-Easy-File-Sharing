import 'package:flutter/foundation.dart';
import 'package:multiads/multiads.dart';

MultiAds? gAds;
bool gAdsReady = false;
bool isInterShowed = false;
bool pastSplash = false;
bool appOpenShownThisSession = false;

/// Hides the bottom banner while overlays such as Quick Transfer are open.
final hideBottomBanner = ValueNotifier<bool>(false);

import 'package:flutter/material.dart';

import '../util/global.dart';

/// Standard bottom banner ad (320×50) above the tab bar.
class BottomAdBanner extends StatefulWidget {
  const BottomAdBanner({super.key, this.adKey = const ValueKey('main_banner')});

  final Key adKey;

  @override
  State<BottomAdBanner> createState() => _BottomAdBannerState();
}

class _BottomAdBannerState extends State<BottomAdBanner> {
  static const _bannerHeight = 50.0;

  bool _loaded = false;
  bool _loadStarted = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (_loadStarted || !gAdsReady || gAds == null || !gAds!.hasBanners) {
      return;
    }
    _loadStarted = true;

    try {
      await gAds!.bannerInstance.loadBannerAd(() {
        if (mounted && (gAds?.hasBanners ?? false)) {
          setState(() => _loaded = true);
        }
      }, widget.adKey);
    } on Object {
      _loadStarted = false;
    }
  }

  @override
  void dispose() {
    if (gAdsReady && gAds != null && gAds!.hasBanners) {
      gAds!.bannerInstance.disposeBanner(widget.adKey);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hideBottomBanner,
      builder: (context, hide, _) {
        if (hide || !gAdsReady || gAds == null || !gAds!.hasBanners) {
          return const SizedBox.shrink();
        }

        if (!_loaded) {
          return const SizedBox(
            height: _bannerHeight,
            width: double.infinity,
          );
        }

        return ColoredBox(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: _bannerHeight,
              width: double.infinity,
              child: Center(
                child: gAds!.bannerInstance.getBannerAdWidget(widget.adKey),
              ),
            ),
          ),
        );
      },
    );
  }
}

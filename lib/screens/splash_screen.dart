import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_scope.dart';
import '../services/ads_actions.dart';
import '../theme/app_theme.dart';
import 'language_selection_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.initializing = false});

  /// True while native plugins / preferences are still loading in [AppBootstrap].
  final bool initializing;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _splashAsset = 'assets/images/splash_screen.png';

  @override
  void initState() {
    super.initState();
    AppTheme.setBlueStatusBar();

    if (!widget.initializing) {
      unawaited(_navigateWhenReady());
    }
  }

  Future<void> _navigateWhenReady() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    await AdsActions.showAppOpenIfAvailable();
    if (!mounted) return;

    final scope = AppScope.of(context);
    final next = scope.isOnboardingComplete
        ? const MainShell()
        : const LanguageSelectionScreen();

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Image.asset(
          _splashAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

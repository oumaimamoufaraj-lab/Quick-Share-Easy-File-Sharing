import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/onboarding_illustrations.dart';
import '../widgets/page_indicator.dart';
import '../widgets/primary_button.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2196F3),
      Color(0xFF1E88E5),
      Color(0xFF1565C0),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  @override
  void initState() {
    super.initState();
    AppTheme.setBlueStatusBar();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<OnboardingPageData> _pages(BuildContext context) {
    final strings = S.of(context);
    return [
      OnboardingPageData(
        title: strings.onboarding1Title,
        compactTitle: strings.onboarding1TitleCompact,
        subtitle: strings.onboarding1Subtitle,
        illustration: const ScanConnectIllustration(),
      ),
      OnboardingPageData(
        title: strings.onboarding2Title,
        compactTitle: strings.onboarding2TitleCompact,
        subtitle: strings.onboarding2Subtitle,
        illustration: const AndroidIosIllustration(),
      ),
      OnboardingPageData(
        title: strings.onboarding3Title,
        subtitle: strings.onboarding3Subtitle,
        illustration: const ShareFilesIllustration(),
      ),
    ];
  }

  Future<void> _onNext(List<OnboardingPageData> pages) async {
    if (_currentPage < pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      return;
    }

    await AppScope.of(context).completeOnboarding();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final pages = _pages(context);
    final buttonLabel =
        _currentPage < pages.length - 1 ? strings.next : strings.getStarted;
    final isCompact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    final title = isCompact && page.compactTitle != null
                        ? page.compactTitle!
                        : page.title;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        isCompact ? 8 : 16,
                        24,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: isCompact ? 24 : 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: isCompact ? 8 : 12),
                          Text(
                            page.subtitle,
                            style: TextStyle(
                              fontSize: isCompact ? 14 : 15,
                              color: Colors.white.withValues(alpha: 0.92),
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: isCompact ? 14 : 18),
                          PageIndicator(
                            count: pages.length,
                            currentIndex: _currentPage,
                          ),
                          SizedBox(height: isCompact ? 8 : 12),
                          Expanded(child: page.illustration),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, isCompact ? 16 : 24),
                child: PrimaryButton(
                  label: buttonLabel,
                  onPressed: () => _onNext(pages),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

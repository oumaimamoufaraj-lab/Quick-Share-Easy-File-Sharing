import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';

class LanguageOption {
  const LanguageOption({
    required this.englishName,
    required this.nativeName,
    required this.letter,
    required this.color,
  });

  final String englishName;
  final String nativeName;
  final String letter;
  final Color color;
}

const languages = <LanguageOption>[
  LanguageOption(
    englishName: 'English',
    nativeName: '(English)',
    letter: 'E',
    color: Color(0xFF007AFF),
  ),
  LanguageOption(
    englishName: 'Hindi',
    nativeName: '(हिंदी)',
    letter: 'H',
    color: Color(0xFFFFCC00),
  ),
  LanguageOption(
    englishName: 'Indonesian',
    nativeName: '(Indonesia)',
    letter: 'I',
    color: Color(0xFFFF9500),
  ),
  LanguageOption(
    englishName: 'French',
    nativeName: '(Français)',
    letter: 'F',
    color: Color(0xFF34C759),
  ),
  LanguageOption(
    englishName: 'German',
    nativeName: '(Deutsch)',
    letter: 'G',
    color: Color(0xFF5AC8FA),
  ),
  LanguageOption(
    englishName: 'Spanish',
    nativeName: '(Española)',
    letter: 'S',
    color: Color(0xFFFF3B30),
  ),
  LanguageOption(
    englishName: 'Portuguese',
    nativeName: '(Português)',
    letter: 'P',
    color: Color(0xFFFF6B35),
  ),
  LanguageOption(
    englishName: 'Italian',
    nativeName: '(Italiano)',
    letter: 'I',
    color: Color(0xFFAF52DE),
  ),
  LanguageOption(
    englishName: 'Russian',
    nativeName: '(Русский)',
    letter: 'R',
    color: Color(0xFF30B0C7),
  ),
];

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key, this.fromSettings = false});

  final bool fromSettings;

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  int _selectedIndex = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    AppTheme.setLightStatusBar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _selectedIndex = AppScope.of(context).languageIndex;
      _loaded = true;
    }
  }

  Future<void> _onDone() async {
    final scope = AppScope.of(context);
    await scope.setLanguage(_selectedIndex);
    if (!mounted) return;

    if (widget.fromSettings) {
      Navigator.of(context).pop();
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  if (widget.fromSettings)
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                  Expanded(
                    child: Text(
                      strings.selectLanguage,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onDone,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      strings.done,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: ListView.separated(
                itemCount: languages.length,
                separatorBuilder: (_, index) => const Divider(
                  height: 1,
                  indent: 76,
                  color: AppColors.divider,
                ),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = index == _selectedIndex;
                  return InkWell(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: lang.color,
                            child: Text(
                              lang.letter,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.englishName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lang.nativeName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

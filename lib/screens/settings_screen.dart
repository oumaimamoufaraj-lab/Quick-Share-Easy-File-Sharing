import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_metadata.dart';
import '../app/app_scope.dart';
import '../l10n/app_strings.dart';
import '../screens/language_selection_screen.dart';
import '../screens/legal/privacy_policy_screen.dart';
import '../screens/legal/terms_screen.dart';
import '../screens/onboarding_screen.dart';
import '../theme/app_colors.dart';
import 'how_to_connect_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = info.version);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              strings.tabSettings,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: CupertinoIcons.globe,
                  title: strings.language,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LanguageSelectionScreen(
                          fromSettings: true,
                        ),
                      ),
                    );
                    if (context.mounted) setState(() {});
                  },
                ),
                _SettingsTile(
                  icon: CupertinoIcons.question_circle,
                  title: strings.howToConnect,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HowToConnectScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: CupertinoIcons.lock_shield,
                  title: strings.privacyPolicy,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  ),
                ),
                _SettingsTile(
                  icon: CupertinoIcons.doc_text,
                  title: strings.termsOfUse,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TermsScreen(),
                    ),
                  ),
                ),
                _SettingsTile(
                  icon: CupertinoIcons.mail,
                  title: strings.support,
                  onTap: () => _openUrl(AppMetadata.supportUrl),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                AppMetadata.supportEmail,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: CupertinoIcons.arrow_counterclockwise,
                  title: strings.resetOnboarding,
                  onTap: () async {
                    await AppScope.of(context).resetOnboarding();
                    if (!context.mounted) return;
                    await Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const OnboardingScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                _SettingsTile(
                  icon: CupertinoIcons.info_circle,
                  title: strings.version,
                  trailing: Text(
                    _version,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: AppColors.textGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

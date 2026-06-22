import 'package:fc_app3_quick_share/util/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_scope.dart';
import 'screens/splash_screen.dart';
import 'services/ads_actions.dart';
import 'services/app_preferences.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

import 'package:http/http.dart' as http;
import 'package:multiads/multiads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var url = Uri.parse(
    "https://drive.google.com/uc?export=download&id=1w3Ls46xTr7WLiFNZWOmtuFnF-KTVou2q",
  );
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      gAds = MultiAds(
        response.body,
        config: MultiAdsConfig(
          admobTestDeviceIds: ['79738754EC81FA5F64972928128B2FFF'],
          facebookTestingId: 'd1a0df1f-2528-4e41-a4d3-1b401ba14f7d',
          enableLogs: true, // set false before release
        ),
      );
      gAdsReady = true;
      await gAds!.init();
      await gAds!.loadAds();
      AdsActions.registerCallbacks();
    }
  } catch (_) {
    // Ads config unavailable; app still launches without ads.
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AppBootstrap());
}

/// Loads native plugins after [runApp] so platform channels are ready.
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppPreferences>(
      future: AppPreferences.load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: PluginSetupScreen(error: snapshot.error),
          );
        }

        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(initializing: true),
          );
        }

        return AppScope(
          controller: AppScopeController(snapshot.data!),
          child: const QuickShareApp(),
        );
      },
    );
  }
}

class QuickShareApp extends StatelessWidget {
  const QuickShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Share: Easy File Sharing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('id'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
        Locale('pt'),
        Locale('it'),
        Locale('ru'),
      ],
      home: const SplashScreen(),
    );
  }
}

class PluginSetupScreen extends StatelessWidget {
  const PluginSetupScreen({super.key, this.error});

  final Object? error;

  bool get _isMissingPlugin =>
      error is MissingPluginException ||
      error.toString().contains('MissingPluginException');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.build_circle_outlined,
                size: 48,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Full rebuild required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isMissingPlugin
                    ? 'Native plugins (like shared_preferences) were added or updated. Hot Restart cannot load them — stop the app completely, then run a fresh build.'
                    : 'Something went wrong while starting the app.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'In VS Code / Cursor:\n'
                '1. Press Stop (not Restart)\n'
                '2. Run: flutter run -d ios',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textDark,
                  fontFamily: 'Menlo',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 20),
                Text(
                  error.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

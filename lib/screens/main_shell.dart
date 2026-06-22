import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner.dart';
import 'receive_screen.dart';
import 'send_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = <Widget>[
    SendScreen(),
    ReceiveScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AppTheme.setLightStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: _screens,
            ),
          ),
          const BottomAdBanner(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.lightBlue,
        destinations: [
          NavigationDestination(
            icon: const Icon(CupertinoIcons.paperplane),
            selectedIcon: const Icon(CupertinoIcons.paperplane_fill),
            label: strings.tabSend,
          ),
          NavigationDestination(
            icon: const Icon(CupertinoIcons.qrcode),
            selectedIcon: const Icon(CupertinoIcons.qrcode_viewfinder),
            label: strings.tabReceive,
          ),
          NavigationDestination(
            icon: const Icon(CupertinoIcons.gear),
            selectedIcon: const Icon(CupertinoIcons.gear_solid),
            label: strings.tabSettings,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class HowToConnectScreen extends StatefulWidget {
  const HowToConnectScreen({super.key});

  @override
  State<HowToConnectScreen> createState() => _HowToConnectScreenState();
}

class _HowToConnectScreenState extends State<HowToConnectScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    AppTheme.setLightStatusBar();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.howToConnect,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(CupertinoIcons.xmark, size: 24),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              tabs: [
                Tab(text: strings.iosTab),
                Tab(text: strings.androidTab),
                Tab(text: strings.webTab),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _GuideList(
                    steps: [
                      strings.step1Ios,
                      strings.step2Ios,
                      strings.step3Ios,
                    ],
                  ),
                  _GuideList(
                    steps: [
                      strings.step1Android,
                      strings.step2Ios,
                      strings.step3Ios,
                    ],
                  ),
                  _GuideList(
                    steps: [
                      strings.step1Web,
                      strings.step2Ios,
                      strings.step3Ios,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideList extends StatelessWidget {
  const _GuideList({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: steps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    steps[index],
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

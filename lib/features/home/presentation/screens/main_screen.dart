import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../coins/data/coins_provider.dart';
import '../../../leaderboard/data/leaderboard_provider.dart';
import '../../../profile/data/profile_provider.dart';
import '../../../redemption/data/redemption_provider.dart';
import '../../data/surveys_provider.dart';
import 'home_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../redemption/presentation/screens/redemption_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LeaderboardScreen(),
    RedemptionScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final coinsProvider = context.read<CoinsProvider>();
    final surveysProvider = context.read<SurveysProvider>();
    final leaderboardProvider = context.read<LeaderboardProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final redemptionProvider = context.read<RedemptionProvider>();

    await Future.wait([
      coinsProvider.loadCoins(),
      surveysProvider.loadSurveys(),
      leaderboardProvider.loadLeaderboards(),
      profileProvider.loadProfile(),
      redemptionProvider.loadOptions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.shadowDark : AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.leaderboard_outlined),
              activeIcon: const Icon(Icons.leaderboard),
              label: l10n.leaderboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.card_giftcard_outlined),
              activeIcon: const Icon(Icons.card_giftcard),
              label: l10n.redeem,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outlined),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}

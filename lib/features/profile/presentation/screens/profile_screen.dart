import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../coins/data/coins_provider.dart';
import '../../data/profile_provider.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<ProfileProvider, CoinsProvider>(
        builder: (context, profile, coins, child) {
          if (profile.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await profile.loadProfile();
              await coins.loadCoins();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(profile, isDark),
                  const SizedBox(height: 24),

                  // Stats Card
                  _buildStatsCard(profile, coins, l10n, isDark),
                  const SizedBox(height: 16),

                  // Rank Progress
                  _buildRankProgress(profile, l10n, isDark),
                  const SizedBox(height: 24),

                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.history,
                    title: l10n.transactionHistory,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionsScreen(),
                        ),
                      );
                    },
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: l10n.aboutUs,
                    onTap: () {
                      _showAboutDialog(context, l10n);
                    },
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: l10n.termsOfService,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.email_outlined,
                    title: l10n.contactSupport,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Sign Out Button
                  _buildSignOutButton(context, l10n),
                  const SizedBox(height: 24),

                  // Version Info
                  Text(
                    '${l10n.version} ${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider profile, bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              profile.initials,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        if (profile.email.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              profile.email,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: profile.rankColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                size: 16,
                color: profile.rankColor,
              ),
              const SizedBox(width: 6),
              Text(
                profile.rankTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: profile.rankColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(
    ProfileProvider profile,
    CoinsProvider coins,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.monetization_on,
            '${coins.totalCoins}',
            l10n.totalCoins,
            AppColors.coinGold,
            isDark,
          ),
          Container(
            width: 1,
            height: 50,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _buildStatItem(
            Icons.check_circle,
            '${profile.stats?.surveysCompleted ?? 0}',
            l10n.surveysCompleted,
            AppColors.success,
            isDark,
          ),
          Container(
            width: 1,
            height: 50,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _buildStatItem(
            Icons.local_fire_department,
            '${coins.streakCount}',
            l10n.streak,
            AppColors.secondary,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRankProgress(
    ProfileProvider profile,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rank Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '${(profile.nextRankProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: profile.nextRankProgress,
              minHeight: 10,
              backgroundColor:
                  isDark ? AppColors.borderDark : AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(profile.rankColor),
            ),
          ),
          const SizedBox(height: 8),
          if (profile.coinsToNextRank > 0)
            Text(
              '${profile.coinsToNextRank} coins to next rank',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showSignOutDialog(context, l10n),
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text(
          l10n.signOut,
          style: const TextStyle(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aboutUs),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.monetization_on,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Paid Surveys',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Earn coins by completing surveys and redeem them for gift cards and cash!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/leaderboard_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = context.read<LeaderboardProvider>();
        switch (_tabController.index) {
          case 0:
            provider.setLeaderboardType(LeaderboardType.global);
            break;
          case 1:
            provider.setLeaderboardType(LeaderboardType.friends);
            break;
          case 2:
            provider.setLeaderboardType(LeaderboardType.weekly);
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: l10n.globalLeaderboard),
                Tab(text: l10n.friendsLeaderboard),
                Tab(text: l10n.weeklyLeaderboard),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<LeaderboardProvider>(
        builder: (context, leaderboard, child) {
          if (leaderboard.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: leaderboard.refresh,
            child: Column(
              children: [
                const SizedBox(height: 16),
                // User's Position Card
                if (leaderboard.currentUserEntry != null)
                  _buildUserPositionCard(
                    leaderboard.currentUserEntry!,
                    l10n,
                    isDark,
                  ),
                const SizedBox(height: 16),
                // Leaderboard List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLeaderboardList(
                        leaderboard.globalLeaderboard,
                        isDark,
                      ),
                      _buildLeaderboardList(
                        leaderboard.friendsLeaderboard,
                        isDark,
                      ),
                      _buildLeaderboardList(
                        leaderboard.weeklyLeaderboard,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserPositionCard(
    LeaderboardEntry entry,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.yourRank,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: AppColors.coinGold,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.coins}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.coins,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries, bool isDark) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildLeaderboardEntry(entry, index, isDark);
      },
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, int index, bool isDark) {
    final isTopThree = int.tryParse(entry.rank) != null &&
        int.parse(entry.rank) <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withOpacity(0.1)
            : isDark
                ? AppColors.cardDark
                : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: isTopThree
                ? _buildRankMedal(int.parse(entry.rank))
                : Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: entry.isCurrentUser
                    ? AppColors.primaryGradient
                    : [Colors.grey.shade400, Colors.grey.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: entry.isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: entry.isCurrentUser
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (entry.isFriend)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.people,
                          size: 16,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Coins
          Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: AppColors.coinGold,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.coins}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankMedal(int rank) {
    Color color;
    IconData icon = Icons.emoji_events;

    switch (rank) {
      case 1:
        color = AppColors.rankGold;
        break;
      case 2:
        color = AppColors.rankSilver;
        break;
      case 3:
        color = AppColors.rankBronze;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}

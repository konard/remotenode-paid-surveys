import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../coins/data/coins_provider.dart';
import '../../data/surveys_provider.dart';
import '../widgets/coin_balance_card.dart';
import '../widgets/daily_bonus_card.dart';
import '../widgets/survey_card.dart';
import '../../../survey/presentation/screens/survey_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<SurveysProvider>().loadSurveys();
          await context.read<CoinsProvider>().loadCoins();
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 100,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeBack,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Consumer<CoinsProvider>(
                      builder: (context, coins, child) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: AppColors.coinGold,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${coins.totalCoins}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.coins,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Daily Bonus Card
                  const DailyBonusCard(),
                  const SizedBox(height: 16),

                  // Coin Balance Card
                  const CoinBalanceCard(),
                  const SizedBox(height: 24),

                  // Featured Surveys Section
                  _buildSectionHeader(l10n, 'Featured', Icons.star),
                  const SizedBox(height: 12),
                  _buildFeaturedSurveys(),
                  const SizedBox(height: 24),

                  // All Surveys Section
                  _buildSectionHeader(l10n, l10n.availableSurveys, Icons.list_alt),
                  const SizedBox(height: 12),
                ]),
              ),
            ),

            // Survey List
            Consumer<SurveysProvider>(
              builder: (context, surveys, child) {
                if (surveys.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final availableSurveys = surveys.availableSurveys;

                if (availableSurveys.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noSurveysAvailable,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.checkBackLater,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final survey = availableSurveys[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SurveyCard(
                            survey: survey,
                            onTap: () => _startSurvey(survey),
                          ),
                        );
                      },
                      childCount: availableSurveys.length,
                    ),
                  ),
                );
              },
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AppLocalizations l10n, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSurveys() {
    return Consumer<SurveysProvider>(
      builder: (context, surveys, child) {
        final featured = surveys.featuredSurveys;

        if (featured.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final survey = featured[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < featured.length - 1 ? 12 : 0,
                ),
                child: SizedBox(
                  width: 280,
                  child: SurveyCard(
                    survey: survey,
                    isFeatured: true,
                    onTap: () => _startSurvey(survey),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _startSurvey(Survey survey) {
    context.read<SurveysProvider>().startSurvey(survey);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SurveyScreen(survey: survey),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/surveys_provider.dart';

class SurveyCard extends StatelessWidget {
  final Survey survey;
  final VoidCallback onTap;
  final bool isFeatured;

  const SurveyCard({
    super.key,
    required this.survey,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isFeatured) {
      return _buildFeaturedCard(context, l10n, isDark);
    }

    return _buildRegularCard(context, l10n, isDark);
  }

  Widget _buildFeaturedCard(BuildContext context, AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getCategoryColor(survey.category),
              _getCategoryColor(survey.category).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getCategoryColor(survey.category).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    survey.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.coinGold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Featured',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              survey.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              survey.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  Icons.monetization_on,
                  '+${survey.coinReward}',
                  AppColors.coinGold,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.access_time,
                  l10n.estimatedTime(survey.estimatedMinutes),
                  Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularCard(BuildContext context, AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getCategoryColor(survey.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getCategoryIcon(survey.category),
                color: _getCategoryColor(survey.category),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          survey.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.coinGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: AppColors.coinGold,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${survey.coinReward}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.coinGoldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    survey.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag(survey.category, _getCategoryColor(survey.category)),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.estimatedTime(survey.estimatedMinutes),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${survey.questions.length}',
                        style: TextStyle(
                          fontSize: 12,
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
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Consumer Research':
        return const Color(0xFF6C63FF);
      case 'Technology':
        return const Color(0xFF00D9A5);
      case 'Lifestyle':
        return const Color(0xFFFF6B6B);
      case 'Entertainment':
        return const Color(0xFFFFB347);
      case 'Health':
        return const Color(0xFF4FC3F7);
      case 'Travel':
        return const Color(0xFF9C27B0);
      case 'Finance':
        return const Color(0xFF2E7D32);
      case 'Work':
        return const Color(0xFF5C6BC0);
      case 'Automotive':
        return const Color(0xFFE53935);
      case 'Food & Drink':
        return const Color(0xFFFF7043);
      case 'Education':
        return const Color(0xFF00897B);
      case 'Environment':
        return const Color(0xFF43A047);
      case 'Family':
        return const Color(0xFFEC407A);
      case 'Media':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Consumer Research':
        return Icons.shopping_cart;
      case 'Technology':
        return Icons.computer;
      case 'Lifestyle':
        return Icons.self_improvement;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.favorite;
      case 'Travel':
        return Icons.flight;
      case 'Finance':
        return Icons.account_balance;
      case 'Work':
        return Icons.work;
      case 'Automotive':
        return Icons.directions_car;
      case 'Food & Drink':
        return Icons.restaurant;
      case 'Education':
        return Icons.school;
      case 'Environment':
        return Icons.eco;
      case 'Family':
        return Icons.family_restroom;
      case 'Media':
        return Icons.newspaper;
      default:
        return Icons.poll;
    }
  }
}

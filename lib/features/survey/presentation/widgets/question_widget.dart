import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home/data/surveys_provider.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final dynamic answer;
  final ValueChanged<dynamic> onAnswerChanged;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text
          Text(
            question.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          if (!question.required)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '(Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Answer Input
          _buildAnswerInput(context, isDark),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(BuildContext context, bool isDark) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoice(isDark);
      case QuestionType.text:
        return _buildTextInput(isDark);
      case QuestionType.rating:
        return _buildRatingInput(isDark);
      case QuestionType.yesNo:
        return _buildYesNoInput(isDark);
    }
  }

  Widget _buildMultipleChoice(bool isDark) {
    final options = question.options ?? [];

    return Column(
      children: options.map((option) {
        final isSelected = answer == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onAnswerChanged(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : isDark
                        ? AppColors.cardDark
                        : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(bool isDark) {
    return TextField(
      onChanged: onAnswerChanged,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Enter your response...',
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingInput(bool isDark) {
    final minRating = question.minRating ?? 1;
    final maxRating = question.maxRating ?? 5;
    final currentRating = answer as int? ?? 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            maxRating - minRating + 1,
            (index) {
              final rating = minRating + index;
              final isSelected = rating <= currentRating;

              return GestureDetector(
                onTap: () => onAnswerChanged(rating),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    size: 48,
                    color: isSelected
                        ? AppColors.coinGold
                        : isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Poor',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            Text(
              'Excellent',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
        if (currentRating > 0)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getRatingLabel(currentRating, maxRating),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getRatingLabel(int rating, int maxRating) {
    final percentage = rating / maxRating;
    if (percentage <= 0.2) return 'Very Poor';
    if (percentage <= 0.4) return 'Below Average';
    if (percentage <= 0.6) return 'Average';
    if (percentage <= 0.8) return 'Good';
    return 'Excellent';
  }

  Widget _buildYesNoInput(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildYesNoOption(
            'Yes',
            Icons.check_circle_outline,
            answer == true,
            () => onAnswerChanged(true),
            isDark,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildYesNoOption(
            'No',
            Icons.cancel_outlined,
            answer == false,
            () => onAnswerChanged(false),
            isDark,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildYesNoOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.1)
              : isDark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected
                  ? accentColor
                  : isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? accentColor
                    : isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

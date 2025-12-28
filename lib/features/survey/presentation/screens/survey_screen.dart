import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../coins/data/coins_provider.dart';
import '../../../home/data/surveys_provider.dart';
import '../widgets/question_widget.dart';
import 'survey_complete_screen.dart';

class SurveyScreen extends StatefulWidget {
  final Survey survey;

  const SurveyScreen({super.key, required this.survey});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeSurvey() async {
    final surveysProvider = context.read<SurveysProvider>();
    final coinsProvider = context.read<CoinsProvider>();

    final success = await surveysProvider.completeSurvey();

    if (success && mounted) {
      await coinsProvider.addSurveyReward(
        widget.survey.coinReward,
        widget.survey.title,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SurveyCompleteScreen(
            survey: widget.survey,
            coinsEarned: widget.survey.coinReward,
          ),
        ),
      );
    }
  }

  void _showExitDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Survey?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SurveysProvider>().cancelSurvey();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close survey screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitDialog,
          ),
          title: Text(widget.survey.title),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.coinGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: AppColors.coinGold,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${widget.survey.coinReward}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.coinGoldDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Consumer<SurveysProvider>(
          builder: (context, surveys, child) {
            return Column(
              children: [
                // Progress Bar
                _buildProgressBar(surveys, isDark),

                // Question Counter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.questionOf(
                      surveys.currentQuestionIndex + 1,
                      surveys.totalQuestions,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),

                // Questions PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.survey.questions.length,
                    onPageChanged: (index) {
                      // Update the provider's current index
                    },
                    itemBuilder: (context, index) {
                      final question = widget.survey.questions[index];
                      return QuestionWidget(
                        question: question,
                        answer: surveys.currentAnswers[question.id],
                        onAnswerChanged: (answer) {
                          surveys.setAnswer(question.id, answer);
                        },
                      );
                    },
                  ),
                ),

                // Navigation Buttons
                _buildNavigationButtons(surveys, l10n, isDark),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar(SurveysProvider surveys, bool isDark) {
    final progress = (surveys.currentQuestionIndex + 1) / surveys.totalQuestions;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    SurveysProvider surveys,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final isFirstQuestion = surveys.currentQuestionIndex == 0;
    final isLastQuestion =
        surveys.currentQuestionIndex == surveys.totalQuestions - 1;
    final canProceed = surveys.canProceed();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Button
            if (!isFirstQuestion)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    surveys.previousQuestion();
                    _goToQuestion(surveys.currentQuestionIndex);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.previous),
                ),
              ),
            if (!isFirstQuestion) const SizedBox(width: 12),

            // Next/Submit Button
            Expanded(
              flex: isFirstQuestion ? 1 : 1,
              child: ElevatedButton.icon(
                onPressed: canProceed
                    ? () {
                        if (isLastQuestion) {
                          _completeSurvey();
                        } else {
                          surveys.nextQuestion();
                          _goToQuestion(surveys.currentQuestionIndex);
                        }
                      }
                    : null,
                icon: Icon(
                  isLastQuestion ? Icons.check : Icons.arrow_forward,
                ),
                label: Text(isLastQuestion ? l10n.submit : l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

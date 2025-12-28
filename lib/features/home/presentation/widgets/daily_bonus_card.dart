import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../coins/data/coins_provider.dart';

class DailyBonusCard extends StatefulWidget {
  const DailyBonusCard({super.key});

  @override
  State<DailyBonusCard> createState() => _DailyBonusCardState();
}

class _DailyBonusCardState extends State<DailyBonusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isClaiming = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _claimBonus() async {
    if (_isClaiming) return;

    final coinsProvider = context.read<CoinsProvider>();
    if (!coinsProvider.canClaimDailyBonus) return;

    setState(() => _isClaiming = true);
    _controller.forward().then((_) => _controller.reverse());

    final success = await coinsProvider.claimDailyBonus();

    if (success && mounted) {
      setState(() {
        _showSuccess = true;
        _isClaiming = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.bonusClaimed,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CoinsProvider>(
      builder: (context, coins, child) {
        if (!coins.canClaimDailyBonus) {
          return const SizedBox.shrink();
        }

        return ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: _claimBonus,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.coinGold.withOpacity(0.9),
                    AppColors.coinGoldLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coinGold.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Gift Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isClaiming
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dailyBonus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${coins.dailyBonusAmount}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (coins.streakCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: AppColors.secondary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${coins.streakCount}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Claim Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.claimBonus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.coinGoldDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

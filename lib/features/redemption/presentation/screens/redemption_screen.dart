import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../coins/data/coins_provider.dart';
import '../../data/redemption_provider.dart';

class RedemptionScreen extends StatefulWidget {
  const RedemptionScreen({super.key});

  @override
  State<RedemptionScreen> createState() => _RedemptionScreenState();
}

class _RedemptionScreenState extends State<RedemptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: Text(l10n.redeemRewards),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: l10n.giftCard),
              Tab(text: l10n.paypal),
              Tab(text: 'Google Play'),
              Tab(text: 'Apple'),
            ],
          ),
        ),
      ),
      body: Consumer2<RedemptionProvider, CoinsProvider>(
        builder: (context, redemption, coins, child) {
          if (redemption.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Coin Balance Header
              _buildCoinBalanceHeader(coins, l10n, isDark),

              // Redemption Options
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOptionsGrid(
                      redemption.options,
                      coins.totalCoins,
                      redemption,
                      isDark,
                    ),
                    _buildOptionsGrid(
                      redemption.getOptionsByType(RedemptionType.amazonGiftCard),
                      coins.totalCoins,
                      redemption,
                      isDark,
                    ),
                    _buildOptionsGrid(
                      redemption.getOptionsByType(RedemptionType.paypal),
                      coins.totalCoins,
                      redemption,
                      isDark,
                    ),
                    _buildOptionsGrid(
                      redemption.getOptionsByType(RedemptionType.googlePlay),
                      coins.totalCoins,
                      redemption,
                      isDark,
                    ),
                    _buildOptionsGrid(
                      redemption.getOptionsByType(RedemptionType.appleStore),
                      coins.totalCoins,
                      redemption,
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoinBalanceHeader(
    CoinsProvider coins,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.coinGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${coins.totalCoins} ${l10n.coins}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(
    List<RedemptionOption> options,
    int userCoins,
    RedemptionProvider provider,
    bool isDark,
  ) {
    if (options.isEmpty) {
      return Center(
        child: Text(
          'No options available',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final canAfford = userCoins >= option.coinCost;

        return _buildOptionCard(option, canAfford, provider, isDark);
      },
    );
  }

  Widget _buildOptionCard(
    RedemptionOption option,
    bool canAfford,
    RedemptionProvider provider,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: canAfford ? () => _showRedeemDialog(option, provider) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: canAfford
              ? Border.all(color: provider.getTypeColor(option.type), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.shadowDark : AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Opacity(
          opacity: canAfford ? 1.0 : 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: provider.getTypeColor(option.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  provider.getTypeIcon(option.type),
                  color: provider.getTypeColor(option.type),
                  size: 28,
                ),
              ),
              const Spacer(),

              // Value
              Text(
                '\$${option.dollarValue.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),

              // Name
              Text(
                option.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),

              // Cost
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: AppColors.coinGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${option.coinCost}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: canAfford
                          ? AppColors.coinGoldDark
                          : isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRedeemDialog(RedemptionOption option, RedemptionProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: provider.getTypeColor(option.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                provider.getTypeIcon(option.type),
                color: provider.getTypeColor(option.type),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              option.description,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: AppColors.coinGold,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${option.coinCost} coins',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.coinGoldDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processRedemption(option, provider);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _processRedemption(
    RedemptionOption option,
    RedemptionProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final coinsProvider = context.read<CoinsProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing redemption...'),
          ],
        ),
      ),
    );

    // Spend coins
    final success = await coinsProvider.spendCoins(
      option.coinCost,
      TransactionType.redemption,
      'Redeemed: ${option.description}',
    );

    if (!success) {
      Navigator.pop(context);
      _showErrorSnackBar(l10n.insufficientCoins);
      return;
    }

    // Process redemption
    final redemption = await provider.redeemOption(option);

    Navigator.pop(context);

    if (redemption != null) {
      _showRedemptionSuccessDialog(redemption, provider);
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Redemption failed');
    }
  }

  void _showRedemptionSuccessDialog(
    Redemption redemption,
    RedemptionProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text(l10n.redeemSuccess),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              redemption.option.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your code:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: SelectableText(
                redemption.code ?? 'N/A',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to copy the code',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

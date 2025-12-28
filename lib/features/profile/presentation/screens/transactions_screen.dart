import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../coins/data/coins_provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionHistory),
      ),
      body: Consumer<CoinsProvider>(
        builder: (context, coins, child) {
          if (coins.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTransactions,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group transactions by date
          final groupedTransactions = _groupTransactionsByDate(coins.transactions);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final date = groupedTransactions.keys.elementAt(index);
              final transactions = groupedTransactions[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _formatDateHeader(date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  ...transactions.map(
                    (transaction) => _buildTransactionItem(
                      transaction,
                      coins,
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.timestamp.year,
        transaction.timestamp.month,
        transaction.timestamp.day,
      );

      if (grouped.containsKey(date)) {
        grouped[date]!.add(transaction);
      } else {
        grouped[date] = [transaction];
      }
    }

    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  Widget _buildTransactionItem(
    Transaction transaction,
    CoinsProvider coins,
    bool isDark,
  ) {
    final isCredit = transaction.isCredit;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTransactionIcon(transaction.type),
              color: isCredit ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coins.getTransactionTypeLabel(transaction.type),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(transaction.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Row(
            children: [
              Text(
                isCredit ? '+' : '-',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.monetization_on,
                color: AppColors.coinGold,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${transaction.amount}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.surveyReward:
        return Icons.poll;
      case TransactionType.dailyBonus:
        return Icons.card_giftcard;
      case TransactionType.streakBonus:
        return Icons.local_fire_department;
      case TransactionType.redemption:
        return Icons.redeem;
      case TransactionType.referral:
        return Icons.people;
    }
  }
}

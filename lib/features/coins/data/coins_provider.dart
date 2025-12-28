import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';

enum TransactionType { surveyReward, dailyBonus, streakBonus, redemption, referral }

class Transaction {
  final String id;
  final TransactionType type;
  final int amount;
  final String description;
  final DateTime timestamp;
  final bool isCredit;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.isCredit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isCredit': isCredit,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: TransactionType.values[map['type']],
      amount: map['amount'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      isCredit: map['isCredit'],
    );
  }
}

class CoinsProvider extends ChangeNotifier {
  int _totalCoins = 0;
  int _lifetimeCoins = 0;
  int _streakCount = 0;
  DateTime? _lastStreakDate;
  bool _canClaimDailyBonus = false;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  int get totalCoins => _totalCoins;
  int get lifetimeCoins => _lifetimeCoins;
  int get streakCount => _streakCount;
  bool get canClaimDailyBonus => _canClaimDailyBonus;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  int get dailyBonusAmount {
    final streakBonus = (_streakCount * AppConstants.streakBonusMultiplier)
        .clamp(0, AppConstants.maxStreakBonus);
    return AppConstants.dailyBonusCoins + streakBonus;
  }

  Future<void> loadCoins() async {
    _isLoading = true;
    notifyListeners();

    _totalCoins = StorageService.getCoins();
    _lifetimeCoins = StorageService.getLifetimeCoins();
    _streakCount = StorageService.getStreakCount();
    _lastStreakDate = StorageService.getLastStreakDate();
    _canClaimDailyBonus = StorageService.canClaimDailyBonus();

    _loadTransactions();
    _checkStreakStatus();

    _isLoading = false;
    notifyListeners();
  }

  void _loadTransactions() {
    final data = StorageService.getTransactions();
    _transactions = data.map((e) => Transaction.fromMap(e)).toList();
  }

  void _checkStreakStatus() {
    if (_lastStreakDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      _lastStreakDate!.year,
      _lastStreakDate!.month,
      _lastStreakDate!.day,
    );

    final diff = today.difference(lastDate).inDays;

    // Reset streak if more than 1 day has passed
    if (diff > 1) {
      _streakCount = 0;
      StorageService.saveStreak(0, now);
    }
  }

  Future<bool> claimDailyBonus() async {
    if (!_canClaimDailyBonus) return false;

    final bonusAmount = dailyBonusAmount;

    // Update streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastStreakDate != null) {
      final lastDate = DateTime(
        _lastStreakDate!.year,
        _lastStreakDate!.month,
        _lastStreakDate!.day,
      );
      final diff = today.difference(lastDate).inDays;

      if (diff == 1) {
        // Continue streak
        _streakCount++;
      } else if (diff > 1) {
        // Reset streak
        _streakCount = 1;
      }
    } else {
      _streakCount = 1;
    }

    _lastStreakDate = now;
    await StorageService.saveStreak(_streakCount, now);
    await StorageService.saveLastDailyBonus(now);

    // Add coins
    await addCoins(
      bonusAmount,
      TransactionType.dailyBonus,
      'Daily bonus + ${_streakCount} day streak',
    );

    _canClaimDailyBonus = false;
    notifyListeners();
    return true;
  }

  Future<void> addCoins(int amount, TransactionType type, String description) async {
    _totalCoins += amount;
    _lifetimeCoins += amount;

    await StorageService.saveCoins(_totalCoins);
    await StorageService.saveLifetimeCoins(_lifetimeCoins);

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      description: description,
      timestamp: DateTime.now(),
      isCredit: true,
    );

    _transactions.insert(0, transaction);
    await StorageService.saveTransaction(transaction.toMap());

    notifyListeners();
  }

  Future<bool> spendCoins(int amount, TransactionType type, String description) async {
    if (_totalCoins < amount) return false;

    _totalCoins -= amount;
    await StorageService.saveCoins(_totalCoins);

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      description: description,
      timestamp: DateTime.now(),
      isCredit: false,
    );

    _transactions.insert(0, transaction);
    await StorageService.saveTransaction(transaction.toMap());

    notifyListeners();
    return true;
  }

  Future<void> addSurveyReward(int amount, String surveyTitle) async {
    await addCoins(
      amount,
      TransactionType.surveyReward,
      'Completed: $surveyTitle',
    );
  }

  String getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.surveyReward:
        return 'Survey Reward';
      case TransactionType.dailyBonus:
        return 'Daily Bonus';
      case TransactionType.streakBonus:
        return 'Streak Bonus';
      case TransactionType.redemption:
        return 'Redemption';
      case TransactionType.referral:
        return 'Referral Bonus';
    }
  }
}

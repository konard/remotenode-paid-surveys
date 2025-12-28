import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class ProfileStats {
  final int totalCoins;
  final int lifetimeCoins;
  final int surveysCompleted;
  final int currentRank;
  final int streakDays;
  final int redemptionsMade;
  final DateTime? memberSince;

  ProfileStats({
    required this.totalCoins,
    required this.lifetimeCoins,
    required this.surveysCompleted,
    required this.currentRank,
    required this.streakDays,
    required this.redemptionsMade,
    this.memberSince,
  });
}

class ProfileProvider extends ChangeNotifier {
  String _userId = '';
  String _name = '';
  String _email = '';
  String _avatarUrl = '';
  bool _isAnonymous = true;
  ProfileStats? _stats;
  bool _isLoading = false;

  String get userId => _userId;
  String get name => _name;
  String get email => _email;
  String get avatarUrl => _avatarUrl;
  bool get isAnonymous => _isAnonymous;
  ProfileStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userId = StorageService.getUserId() ?? '';
      _name = StorageService.getUserName() ?? 'Guest User';
      _email = StorageService.getUserEmail() ?? '';
      _isAnonymous = StorageService.isAnonymous();

      final completedSurveys = StorageService.getCompletedSurveys();
      final transactions = StorageService.getTransactions();
      final redemptions = transactions.where((t) => t['type'] == 3).length; // TransactionType.redemption

      _stats = ProfileStats(
        totalCoins: StorageService.getCoins(),
        lifetimeCoins: StorageService.getLifetimeCoins(),
        surveysCompleted: completedSurveys.length,
        currentRank: _calculateRank(StorageService.getLifetimeCoins()),
        streakDays: StorageService.getStreakCount(),
        redemptionsMade: redemptions,
        memberSince: _getMemberSinceDate(),
      );
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  int _calculateRank(int lifetimeCoins) {
    // Mock rank calculation based on coins
    if (lifetimeCoins >= 25000) return 1;
    if (lifetimeCoins >= 20000) return 5;
    if (lifetimeCoins >= 15000) return 10;
    if (lifetimeCoins >= 10000) return 20;
    if (lifetimeCoins >= 5000) return 35;
    if (lifetimeCoins >= 2000) return 50;
    if (lifetimeCoins >= 500) return 75;
    return 100;
  }

  DateTime? _getMemberSinceDate() {
    // In a real app, this would be stored
    // For mock, return a date from the past
    return DateTime.now().subtract(const Duration(days: 30));
  }

  Future<bool> updateProfile({String? name, String? avatarUrl}) async {
    try {
      if (name != null && name.isNotEmpty) {
        _name = name;
      }
      if (avatarUrl != null) {
        _avatarUrl = avatarUrl;
      }

      await StorageService.saveUser(
        id: _userId,
        email: _email.isNotEmpty ? _email : null,
        name: _name,
        isAnonymous: _isAnonymous,
      );

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  String get initials {
    if (_name.isEmpty) return 'G';
    final parts = _name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _name[0].toUpperCase();
  }

  String get rankTitle {
    final rank = _stats?.currentRank ?? 100;
    if (rank <= 3) return 'Survey Legend';
    if (rank <= 10) return 'Elite Surveyor';
    if (rank <= 25) return 'Pro Respondent';
    if (rank <= 50) return 'Active Member';
    if (rank <= 75) return 'Rising Star';
    return 'Newcomer';
  }

  Color get rankColor {
    final rank = _stats?.currentRank ?? 100;
    if (rank <= 3) return const Color(0xFFFFD700); // Gold
    if (rank <= 10) return const Color(0xFFC0C0C0); // Silver
    if (rank <= 25) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF6C63FF); // Primary
  }

  double get nextRankProgress {
    final coins = _stats?.lifetimeCoins ?? 0;
    if (coins >= 25000) return 1.0;
    if (coins >= 20000) return (coins - 20000) / 5000;
    if (coins >= 15000) return (coins - 15000) / 5000;
    if (coins >= 10000) return (coins - 10000) / 5000;
    if (coins >= 5000) return (coins - 5000) / 5000;
    if (coins >= 2000) return (coins - 2000) / 3000;
    if (coins >= 500) return (coins - 500) / 1500;
    return coins / 500;
  }

  int get coinsToNextRank {
    final coins = _stats?.lifetimeCoins ?? 0;
    if (coins >= 25000) return 0;
    if (coins >= 20000) return 25000 - coins;
    if (coins >= 15000) return 20000 - coins;
    if (coins >= 10000) return 15000 - coins;
    if (coins >= 5000) return 10000 - coins;
    if (coins >= 2000) return 5000 - coins;
    if (coins >= 500) return 2000 - coins;
    return 500 - coins;
  }
}

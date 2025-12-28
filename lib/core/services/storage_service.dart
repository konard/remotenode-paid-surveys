import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late Box _userBox;
  static late Box _coinsBox;
  static late Box _surveysBox;
  static late Box _leaderboardBox;
  static late Box _settingsBox;
  static late Box _transactionsBox;

  static Future<void> init() async {
    _userBox = await Hive.openBox(AppConstants.userBox);
    _coinsBox = await Hive.openBox(AppConstants.coinsBox);
    _surveysBox = await Hive.openBox(AppConstants.surveysBox);
    _leaderboardBox = await Hive.openBox(AppConstants.leaderboardBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _transactionsBox = await Hive.openBox(AppConstants.transactionsBox);
  }

  // User Methods
  static Future<void> saveUser({
    required String id,
    String? email,
    String? name,
    bool isAnonymous = false,
  }) async {
    await _userBox.put(AppConstants.userIdKey, id);
    await _userBox.put(AppConstants.userEmailKey, email);
    await _userBox.put(AppConstants.userNameKey, name);
    await _userBox.put(AppConstants.isAnonymousKey, isAnonymous);
    await _userBox.put(AppConstants.isLoggedInKey, true);
  }

  static String? getUserId() => _userBox.get(AppConstants.userIdKey);
  static String? getUserEmail() => _userBox.get(AppConstants.userEmailKey);
  static String? getUserName() => _userBox.get(AppConstants.userNameKey);
  static bool isLoggedIn() => _userBox.get(AppConstants.isLoggedInKey, defaultValue: false);
  static bool isAnonymous() => _userBox.get(AppConstants.isAnonymousKey, defaultValue: true);

  static Future<void> logout() async {
    await _userBox.clear();
  }

  // Coins Methods
  static Future<void> saveCoins(int coins) async {
    await _coinsBox.put(AppConstants.totalCoinsKey, coins);
  }

  static int getCoins() => _coinsBox.get(AppConstants.totalCoinsKey, defaultValue: 0);

  static Future<void> saveLifetimeCoins(int coins) async {
    await _coinsBox.put(AppConstants.lifetimeCoinsKey, coins);
  }

  static int getLifetimeCoins() => _coinsBox.get(AppConstants.lifetimeCoinsKey, defaultValue: 0);

  static Future<void> addCoins(int amount) async {
    final current = getCoins();
    final lifetime = getLifetimeCoins();
    await saveCoins(current + amount);
    await saveLifetimeCoins(lifetime + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    final current = getCoins();
    if (current >= amount) {
      await saveCoins(current - amount);
      return true;
    }
    return false;
  }

  // Streak Methods
  static Future<void> saveStreak(int count, DateTime date) async {
    await _coinsBox.put(AppConstants.streakCountKey, count);
    await _coinsBox.put(AppConstants.lastStreakDateKey, date.toIso8601String());
  }

  static int getStreakCount() => _coinsBox.get(AppConstants.streakCountKey, defaultValue: 0);

  static DateTime? getLastStreakDate() {
    final dateStr = _coinsBox.get(AppConstants.lastStreakDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  // Daily Bonus Methods
  static Future<void> saveLastDailyBonus(DateTime date) async {
    await _coinsBox.put(AppConstants.lastDailyBonusKey, date.toIso8601String());
  }

  static DateTime? getLastDailyBonus() {
    final dateStr = _coinsBox.get(AppConstants.lastDailyBonusKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  static bool canClaimDailyBonus() {
    final lastBonus = getLastDailyBonus();
    if (lastBonus == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastBonusDay = DateTime(lastBonus.year, lastBonus.month, lastBonus.day);

    return today.isAfter(lastBonusDay);
  }

  // Surveys Methods
  static Future<void> saveCompletedSurvey(String surveyId) async {
    final completed = getCompletedSurveys();
    if (!completed.contains(surveyId)) {
      completed.add(surveyId);
      await _surveysBox.put('completed_surveys', completed);
    }
  }

  static List<String> getCompletedSurveys() {
    final data = _surveysBox.get('completed_surveys');
    if (data == null) return [];
    return List<String>.from(data);
  }

  static bool isSurveyCompleted(String surveyId) {
    return getCompletedSurveys().contains(surveyId);
  }

  // Transactions Methods
  static Future<void> saveTransaction(Map<String, dynamic> transaction) async {
    final transactions = getTransactions();
    transactions.insert(0, transaction);
    await _transactionsBox.put('transactions', transactions);
  }

  static List<Map<String, dynamic>> getTransactions() {
    final data = _transactionsBox.get('transactions');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e)));
  }

  // Settings Methods
  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _settingsBox.put(AppConstants.themeModeKey, mode.index);
  }

  static Future<ThemeMode> getThemeMode() async {
    final index = _settingsBox.get(AppConstants.themeModeKey, defaultValue: 0);
    return ThemeMode.values[index];
  }

  static Future<void> saveLocale(Locale locale) async {
    await _settingsBox.put(AppConstants.localeKey, locale.languageCode);
  }

  static Future<Locale> getLocale() async {
    final code = _settingsBox.get(AppConstants.localeKey, defaultValue: 'en');
    return Locale(code);
  }

  static Future<void> saveNotificationsEnabled(bool enabled) async {
    await _settingsBox.put(AppConstants.notificationsEnabledKey, enabled);
  }

  static bool getNotificationsEnabled() {
    return _settingsBox.get(AppConstants.notificationsEnabledKey, defaultValue: true);
  }

  // Leaderboard Cache
  static Future<void> cacheLeaderboard(List<Map<String, dynamic>> leaderboard) async {
    await _leaderboardBox.put('leaderboard_cache', leaderboard);
    await _leaderboardBox.put('leaderboard_cache_time', DateTime.now().toIso8601String());
  }

  static List<Map<String, dynamic>>? getCachedLeaderboard() {
    final data = _leaderboardBox.get('leaderboard_cache');
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e)));
  }

  static bool isLeaderboardCacheValid() {
    final cacheTime = _leaderboardBox.get('leaderboard_cache_time');
    if (cacheTime == null) return false;

    final cachedAt = DateTime.parse(cacheTime);
    final diff = DateTime.now().difference(cachedAt);
    return diff.inMinutes < 30; // Cache valid for 30 minutes
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _userBox.clear();
    await _coinsBox.clear();
    await _surveysBox.clear();
    await _leaderboardBox.clear();
    await _settingsBox.clear();
    await _transactionsBox.clear();
  }
}

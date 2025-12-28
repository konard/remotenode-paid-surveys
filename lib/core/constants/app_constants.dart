class AppConstants {
  static const String appName = 'Paid Surveys';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String userBox = 'user_box';
  static const String coinsBox = 'coins_box';
  static const String surveysBox = 'surveys_box';
  static const String leaderboardBox = 'leaderboard_box';
  static const String settingsBox = 'settings_box';
  static const String transactionsBox = 'transactions_box';

  // User Keys
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String isLoggedInKey = 'is_logged_in';
  static const String isAnonymousKey = 'is_anonymous';

  // Coins Keys
  static const String totalCoinsKey = 'total_coins';
  static const String lifetimeCoinsKey = 'lifetime_coins';
  static const String lastDailyBonusKey = 'last_daily_bonus';
  static const String streakCountKey = 'streak_count';
  static const String lastStreakDateKey = 'last_streak_date';

  // Settings Keys
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Coin Values
  static const int dailyBonusCoins = 10;
  static const int streakBonusMultiplier = 5;
  static const int maxStreakBonus = 50;
  static const int referralBonus = 100;

  // Redemption Thresholds
  static const int minRedemptionCoins = 500;
  static const int giftCard5Value = 500;
  static const int giftCard10Value = 1000;
  static const int giftCard25Value = 2500;
  static const int giftCard50Value = 5000;

  // Survey Constants
  static const int maxDailySurveys = 20;
  static const Duration surveyRefreshInterval = Duration(hours: 6);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // API Endpoints (mock)
  static const String baseUrl = 'https://api.paidsurveys.example.com';
  static const String surveysEndpoint = '/surveys';
  static const String leaderboardEndpoint = '/leaderboard';
  static const String redeemEndpoint = '/redeem';
}

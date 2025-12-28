import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('es'),
  ];

  String get appName;
  String get home;
  String get surveys;
  String get leaderboard;
  String get profile;
  String get redeem;
  String get coins;
  String get welcomeBack;
  String get dailyBonus;
  String get claimBonus;
  String get bonusClaimed;
  String get streak;
  String get days;
  String get availableSurveys;
  String get startSurvey;
  String get continueSurvey;
  String get completeSurvey;
  String get surveyCompleted;
  String earnedCoins(int coins);
  String estimatedTime(int minutes);
  String questionOf(int current, int total);
  String get next;
  String get previous;
  String get submit;
  String get skip;
  String get globalLeaderboard;
  String get friendsLeaderboard;
  String get weeklyLeaderboard;
  String get rank;
  String get yourRank;
  String get totalCoins;
  String get lifetimeEarnings;
  String get surveysCompleted;
  String get redeemRewards;
  String get giftCard;
  String get paypal;
  String get redeemNow;
  String get insufficientCoins;
  String get redeemSuccess;
  String get redeemPending;
  String get transactionHistory;
  String get noTransactions;
  String get signIn;
  String get signUp;
  String get signOut;
  String get continueAsGuest;
  String get email;
  String get password;
  String get confirmPassword;
  String get name;
  String get forgotPassword;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get settings;
  String get theme;
  String get lightTheme;
  String get darkTheme;
  String get systemTheme;
  String get language;
  String get notifications;
  String get enableNotifications;
  String get privacyPolicy;
  String get termsOfService;
  String get aboutUs;
  String get contactSupport;
  String get version;
  String get loading;
  String get error;
  String get retry;
  String get noSurveysAvailable;
  String get checkBackLater;
  String get congratulations;
  String get keepItUp;
  String get cancel;
  String get confirm;
  String get save;
  String get close;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }
  return AppLocalizationsEn();
}

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([super.locale = 'en']);

  @override
  String get appName => 'Paid Surveys';
  @override
  String get home => 'Home';
  @override
  String get surveys => 'Surveys';
  @override
  String get leaderboard => 'Leaderboard';
  @override
  String get profile => 'Profile';
  @override
  String get redeem => 'Redeem';
  @override
  String get coins => 'Coins';
  @override
  String get welcomeBack => 'Welcome back!';
  @override
  String get dailyBonus => 'Daily Bonus';
  @override
  String get claimBonus => 'Claim Bonus';
  @override
  String get bonusClaimed => 'Bonus claimed!';
  @override
  String get streak => 'Streak';
  @override
  String get days => 'days';
  @override
  String get availableSurveys => 'Available Surveys';
  @override
  String get startSurvey => 'Start Survey';
  @override
  String get continueSurvey => 'Continue';
  @override
  String get completeSurvey => 'Complete';
  @override
  String get surveyCompleted => 'Survey Completed!';
  @override
  String earnedCoins(int coins) => 'You earned $coins coins!';
  @override
  String estimatedTime(int minutes) => '$minutes min';
  @override
  String questionOf(int current, int total) => 'Question $current of $total';
  @override
  String get next => 'Next';
  @override
  String get previous => 'Previous';
  @override
  String get submit => 'Submit';
  @override
  String get skip => 'Skip';
  @override
  String get globalLeaderboard => 'Global';
  @override
  String get friendsLeaderboard => 'Friends';
  @override
  String get weeklyLeaderboard => 'Weekly';
  @override
  String get rank => 'Rank';
  @override
  String get yourRank => 'Your Rank';
  @override
  String get totalCoins => 'Total Coins';
  @override
  String get lifetimeEarnings => 'Lifetime Earnings';
  @override
  String get surveysCompleted => 'Surveys Completed';
  @override
  String get redeemRewards => 'Redeem Rewards';
  @override
  String get giftCard => 'Gift Card';
  @override
  String get paypal => 'PayPal';
  @override
  String get redeemNow => 'Redeem Now';
  @override
  String get insufficientCoins => 'Insufficient coins';
  @override
  String get redeemSuccess => 'Redemption successful!';
  @override
  String get redeemPending => 'Redemption pending';
  @override
  String get transactionHistory => 'Transaction History';
  @override
  String get noTransactions => 'No transactions yet';
  @override
  String get signIn => 'Sign In';
  @override
  String get signUp => 'Sign Up';
  @override
  String get signOut => 'Sign Out';
  @override
  String get continueAsGuest => 'Continue as Guest';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get name => 'Name';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get alreadyHaveAccount => 'Already have an account?';
  @override
  String get dontHaveAccount => "Don't have an account?";
  @override
  String get settings => 'Settings';
  @override
  String get theme => 'Theme';
  @override
  String get lightTheme => 'Light';
  @override
  String get darkTheme => 'Dark';
  @override
  String get systemTheme => 'System';
  @override
  String get language => 'Language';
  @override
  String get notifications => 'Notifications';
  @override
  String get enableNotifications => 'Enable Notifications';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get termsOfService => 'Terms of Service';
  @override
  String get aboutUs => 'About Us';
  @override
  String get contactSupport => 'Contact Support';
  @override
  String get version => 'Version';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get retry => 'Retry';
  @override
  String get noSurveysAvailable => 'No surveys available';
  @override
  String get checkBackLater => 'Check back later for new surveys!';
  @override
  String get congratulations => 'Congratulations!';
  @override
  String get keepItUp => 'Keep it up!';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get save => 'Save';
  @override
  String get close => 'Close';
}

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([super.locale = 'ru']);

  @override
  String get appName => 'Платные Опросы';
  @override
  String get home => 'Главная';
  @override
  String get surveys => 'Опросы';
  @override
  String get leaderboard => 'Рейтинг';
  @override
  String get profile => 'Профиль';
  @override
  String get redeem => 'Обменять';
  @override
  String get coins => 'Монеты';
  @override
  String get welcomeBack => 'С возвращением!';
  @override
  String get dailyBonus => 'Ежедневный бонус';
  @override
  String get claimBonus => 'Получить бонус';
  @override
  String get bonusClaimed => 'Бонус получен!';
  @override
  String get streak => 'Серия';
  @override
  String get days => 'дней';
  @override
  String get availableSurveys => 'Доступные опросы';
  @override
  String get startSurvey => 'Начать опрос';
  @override
  String get continueSurvey => 'Продолжить';
  @override
  String get completeSurvey => 'Завершить';
  @override
  String get surveyCompleted => 'Опрос завершён!';
  @override
  String earnedCoins(int coins) => 'Вы заработали $coins монет!';
  @override
  String estimatedTime(int minutes) => '$minutes мин';
  @override
  String questionOf(int current, int total) => 'Вопрос $current из $total';
  @override
  String get next => 'Далее';
  @override
  String get previous => 'Назад';
  @override
  String get submit => 'Отправить';
  @override
  String get skip => 'Пропустить';
  @override
  String get globalLeaderboard => 'Глобальный';
  @override
  String get friendsLeaderboard => 'Друзья';
  @override
  String get weeklyLeaderboard => 'Недельный';
  @override
  String get rank => 'Ранг';
  @override
  String get yourRank => 'Ваш ранг';
  @override
  String get totalCoins => 'Всего монет';
  @override
  String get lifetimeEarnings => 'Заработано всего';
  @override
  String get surveysCompleted => 'Опросов завершено';
  @override
  String get redeemRewards => 'Обменять награды';
  @override
  String get giftCard => 'Подарочная карта';
  @override
  String get paypal => 'PayPal';
  @override
  String get redeemNow => 'Обменять сейчас';
  @override
  String get insufficientCoins => 'Недостаточно монет';
  @override
  String get redeemSuccess => 'Обмен успешен!';
  @override
  String get redeemPending => 'Обмен в обработке';
  @override
  String get transactionHistory => 'История транзакций';
  @override
  String get noTransactions => 'Транзакций пока нет';
  @override
  String get signIn => 'Войти';
  @override
  String get signUp => 'Регистрация';
  @override
  String get signOut => 'Выйти';
  @override
  String get continueAsGuest => 'Продолжить как гость';
  @override
  String get email => 'Email';
  @override
  String get password => 'Пароль';
  @override
  String get confirmPassword => 'Подтвердите пароль';
  @override
  String get name => 'Имя';
  @override
  String get forgotPassword => 'Забыли пароль?';
  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';
  @override
  String get dontHaveAccount => 'Нет аккаунта?';
  @override
  String get settings => 'Настройки';
  @override
  String get theme => 'Тема';
  @override
  String get lightTheme => 'Светлая';
  @override
  String get darkTheme => 'Тёмная';
  @override
  String get systemTheme => 'Системная';
  @override
  String get language => 'Язык';
  @override
  String get notifications => 'Уведомления';
  @override
  String get enableNotifications => 'Включить уведомления';
  @override
  String get privacyPolicy => 'Политика конфиденциальности';
  @override
  String get termsOfService => 'Условия использования';
  @override
  String get aboutUs => 'О нас';
  @override
  String get contactSupport => 'Связаться с поддержкой';
  @override
  String get version => 'Версия';
  @override
  String get loading => 'Загрузка...';
  @override
  String get error => 'Ошибка';
  @override
  String get retry => 'Повторить';
  @override
  String get noSurveysAvailable => 'Опросы недоступны';
  @override
  String get checkBackLater => 'Загляните позже за новыми опросами!';
  @override
  String get congratulations => 'Поздравляем!';
  @override
  String get keepItUp => 'Так держать!';
  @override
  String get cancel => 'Отмена';
  @override
  String get confirm => 'Подтвердить';
  @override
  String get save => 'Сохранить';
  @override
  String get close => 'Закрыть';
}

/// The translations for Spanish (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([super.locale = 'es']);

  @override
  String get appName => 'Encuestas Pagadas';
  @override
  String get home => 'Inicio';
  @override
  String get surveys => 'Encuestas';
  @override
  String get leaderboard => 'Clasificación';
  @override
  String get profile => 'Perfil';
  @override
  String get redeem => 'Canjear';
  @override
  String get coins => 'Monedas';
  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';
  @override
  String get dailyBonus => 'Bonificación diaria';
  @override
  String get claimBonus => 'Reclamar bonificación';
  @override
  String get bonusClaimed => '¡Bonificación reclamada!';
  @override
  String get streak => 'Racha';
  @override
  String get days => 'días';
  @override
  String get availableSurveys => 'Encuestas disponibles';
  @override
  String get startSurvey => 'Iniciar encuesta';
  @override
  String get continueSurvey => 'Continuar';
  @override
  String get completeSurvey => 'Completar';
  @override
  String get surveyCompleted => '¡Encuesta completada!';
  @override
  String earnedCoins(int coins) => '¡Ganaste $coins monedas!';
  @override
  String estimatedTime(int minutes) => '$minutes min';
  @override
  String questionOf(int current, int total) => 'Pregunta $current de $total';
  @override
  String get next => 'Siguiente';
  @override
  String get previous => 'Anterior';
  @override
  String get submit => 'Enviar';
  @override
  String get skip => 'Omitir';
  @override
  String get globalLeaderboard => 'Global';
  @override
  String get friendsLeaderboard => 'Amigos';
  @override
  String get weeklyLeaderboard => 'Semanal';
  @override
  String get rank => 'Rango';
  @override
  String get yourRank => 'Tu rango';
  @override
  String get totalCoins => 'Monedas totales';
  @override
  String get lifetimeEarnings => 'Ganancias totales';
  @override
  String get surveysCompleted => 'Encuestas completadas';
  @override
  String get redeemRewards => 'Canjear recompensas';
  @override
  String get giftCard => 'Tarjeta de regalo';
  @override
  String get paypal => 'PayPal';
  @override
  String get redeemNow => 'Canjear ahora';
  @override
  String get insufficientCoins => 'Monedas insuficientes';
  @override
  String get redeemSuccess => '¡Canje exitoso!';
  @override
  String get redeemPending => 'Canje pendiente';
  @override
  String get transactionHistory => 'Historial de transacciones';
  @override
  String get noTransactions => 'Sin transacciones aún';
  @override
  String get signIn => 'Iniciar sesión';
  @override
  String get signUp => 'Registrarse';
  @override
  String get signOut => 'Cerrar sesión';
  @override
  String get continueAsGuest => 'Continuar como invitado';
  @override
  String get email => 'Correo electrónico';
  @override
  String get password => 'Contraseña';
  @override
  String get confirmPassword => 'Confirmar contraseña';
  @override
  String get name => 'Nombre';
  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';
  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';
  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';
  @override
  String get settings => 'Configuración';
  @override
  String get theme => 'Tema';
  @override
  String get lightTheme => 'Claro';
  @override
  String get darkTheme => 'Oscuro';
  @override
  String get systemTheme => 'Sistema';
  @override
  String get language => 'Idioma';
  @override
  String get notifications => 'Notificaciones';
  @override
  String get enableNotifications => 'Activar notificaciones';
  @override
  String get privacyPolicy => 'Política de privacidad';
  @override
  String get termsOfService => 'Términos de servicio';
  @override
  String get aboutUs => 'Sobre nosotros';
  @override
  String get contactSupport => 'Contactar soporte';
  @override
  String get version => 'Versión';
  @override
  String get loading => 'Cargando...';
  @override
  String get error => 'Error';
  @override
  String get retry => 'Reintentar';
  @override
  String get noSurveysAvailable => 'No hay encuestas disponibles';
  @override
  String get checkBackLater => '¡Vuelve más tarde para nuevas encuestas!';
  @override
  String get congratulations => '¡Felicitaciones!';
  @override
  String get keepItUp => '¡Sigue así!';
  @override
  String get cancel => 'Cancelar';
  @override
  String get confirm => 'Confirmar';
  @override
  String get save => 'Guardar';
  @override
  String get close => 'Cerrar';
}

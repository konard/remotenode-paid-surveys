import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await StorageService.getThemeMode();
    final locale = await StorageService.getLocale();
    final notifications = StorageService.getNotificationsEnabled();

    setState(() {
      _themeMode = themeMode;
      _locale = locale;
      _notificationsEnabled = notifications;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await StorageService.saveThemeMode(mode);

    // Update app theme
    final toggleTheme =
        context.read<void Function(ThemeMode)>();
    toggleTheme(mode);
  }

  Future<void> _setLocale(Locale locale) async {
    setState(() => _locale = locale);
    await StorageService.saveLocale(locale);

    // Update app locale
    final setLocale = context.read<void Function(Locale)>();
    setLocale(locale);
  }

  Future<void> _setNotifications(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    await StorageService.saveNotificationsEnabled(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          _buildSectionHeader(l10n.theme, Icons.palette, isDark),
          const SizedBox(height: 12),
          _buildThemeSelector(l10n, isDark),
          const SizedBox(height: 24),

          // Language Section
          _buildSectionHeader(l10n.language, Icons.language, isDark),
          const SizedBox(height: 12),
          _buildLanguageSelector(l10n, isDark),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(l10n.notifications, Icons.notifications, isDark),
          const SizedBox(height: 12),
          _buildNotificationsToggle(l10n, isDark),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(AppLocalizations l10n, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildThemeOption(
            l10n.systemTheme,
            Icons.settings_suggest,
            ThemeMode.system,
            isDark,
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _buildThemeOption(
            l10n.lightTheme,
            Icons.light_mode,
            ThemeMode.light,
            isDark,
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _buildThemeOption(
            l10n.darkTheme,
            Icons.dark_mode,
            ThemeMode.dark,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    IconData icon,
    ThemeMode mode,
    bool isDark,
  ) {
    final isSelected = _themeMode == mode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppColors.primary
            : isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? AppColors.primary
              : isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () => _setThemeMode(mode),
    );
  }

  Widget _buildLanguageSelector(AppLocalizations l10n, bool isDark) {
    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: languages.asMap().entries.map((entry) {
          final index = entry.key;
          final lang = entry.value;
          final isSelected = _locale.languageCode == lang['code'];

          return Column(
            children: [
              ListTile(
                leading: Text(
                  lang['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  lang['name']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () => _setLocale(Locale(lang['code']!)),
              ),
              if (index < languages.length - 1)
                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationsToggle(AppLocalizations l10n, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          l10n.enableNotifications,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          'Receive reminders about new surveys and bonuses',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        value: _notificationsEnabled,
        onChanged: _setNotifications,
        activeColor: AppColors.primary,
      ),
    );
  }
}

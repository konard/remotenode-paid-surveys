# Paid Surveys

A production-ready Flutter mobile application for completing surveys and earning coins, with gamification features including leaderboards, daily bonuses, streaks, and reward redemption.

## Features

### Core Features
- **User Authentication**: Anonymous or email-based sign-up/sign-in
- **Survey System**: Dynamic surveys with multiple question types (multiple choice, text, rating, yes/no)
- **Coin Economy**: Earn coins for completing surveys, claim daily bonuses
- **Leaderboard**: Global, friends, and weekly rankings with user position highlighting
- **Redemption**: Convert coins to gift cards (Amazon, PayPal, Google Play, Apple, Visa)
- **Profile**: User stats, rank progression, and transaction history

### Gamification
- Daily bonus with streak multipliers
- Rank progression system (Newcomer → Survey Legend)
- Featured surveys with higher rewards
- Visual feedback and animations for achievements

### Technical Features
- Multi-language support (English, Russian, Spanish)
- Dark/Light theme with Material 3 design
- Responsive layout for phones and tablets
- Local data persistence with Hive
- Push notification support (Firebase Messaging ready)
- Clean architecture with Provider state management

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── constants/               # App constants and colors
│   ├── services/                # Storage and notification services
│   ├── theme/                   # Material 3 theme configuration
│   └── widgets/                 # Shared widgets
├── features/
│   ├── auth/                    # Authentication
│   ├── home/                    # Home screen and surveys list
│   ├── survey/                  # Survey taking flow
│   ├── coins/                   # Coin balance and transactions
│   ├── leaderboard/             # Rankings
│   ├── profile/                 # User profile and settings
│   └── redemption/              # Rewards redemption
└── l10n/                        # Localization files
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/paid-surveys.git
cd paid-surveys
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Run the app:
```bash
flutter run
```

## Configuration

### Firebase Setup (Optional)
1. Create a Firebase project at https://console.firebase.google.com
2. Add your Android and iOS apps
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories
5. Uncomment Firebase initialization in `main.dart`

### App Icons and Splash Screen
```bash
# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## Release Build

### Android

1. Create a keystore for signing:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. Update `android/app/build.gradle` to use the keystore for release builds

4. Build the release APK:
```bash
flutter build apk --release
```

5. Or build App Bundle for Play Store:
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing with your Apple Developer account
3. Set the bundle identifier and team
4. Build for release:
```bash
flutter build ios --release
```

5. Archive and upload to App Store Connect from Xcode

## Customization

### Adding New Languages
1. Create a new `.arb` file in `lib/l10n/` (e.g., `app_fr.arb`)
2. Add translations following the format in `app_en.arb`
3. Update `AppLocalizations.supportedLocales` in `app_localizations.dart`
4. Run `flutter gen-l10n`

### Adding New Surveys
Edit `lib/features/home/data/surveys_provider.dart` and add surveys to the `_getMockSurveys()` method.

### Theming
Modify colors in `lib/core/constants/app_colors.dart` and themes in `lib/core/theme/app_theme.dart`.

## Dependencies

| Package | Purpose |
|---------|---------|
| provider | State management |
| hive_flutter | Local storage |
| firebase_core | Firebase initialization |
| firebase_messaging | Push notifications |
| flutter_localizations | Multi-language support |
| intl | Date/number formatting |
| uuid | Unique ID generation |
| percent_indicator | Progress indicators |

## Mock Data

The app includes 22 mock surveys covering categories:
- Consumer Research
- Technology
- Lifestyle
- Entertainment
- Health
- Travel
- Finance
- Work
- And more...

## License

This project is licensed under the MIT License.

## Support

For issues and feature requests, please create an issue on GitHub.

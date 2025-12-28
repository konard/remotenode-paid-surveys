import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

enum RedemptionType { amazonGiftCard, paypal, googlePlay, appleStore, visa }

enum RedemptionStatus { pending, processing, completed, failed }

class RedemptionOption {
  final String id;
  final String name;
  final String description;
  final RedemptionType type;
  final int coinCost;
  final double dollarValue;
  final String iconAsset;
  final bool isAvailable;

  RedemptionOption({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.coinCost,
    required this.dollarValue,
    this.iconAsset = '',
    this.isAvailable = true,
  });
}

class Redemption {
  final String id;
  final RedemptionOption option;
  final int coinSpent;
  final RedemptionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? code;
  final String? errorMessage;

  Redemption({
    required this.id,
    required this.option,
    required this.coinSpent,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.code,
    this.errorMessage,
  });
}

class RedemptionProvider extends ChangeNotifier {
  List<RedemptionOption> _options = [];
  List<Redemption> _redemptions = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;

  List<RedemptionOption> get options => _options;
  List<Redemption> get redemptions => _redemptions;
  List<Redemption> get pendingRedemptions =>
      _redemptions.where((r) => r.status == RedemptionStatus.pending || r.status == RedemptionStatus.processing).toList();
  List<Redemption> get completedRedemptions =>
      _redemptions.where((r) => r.status == RedemptionStatus.completed).toList();
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  Future<void> loadOptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _options = [
        RedemptionOption(
          id: 'amazon_5',
          name: 'Amazon Gift Card',
          description: '\$5 Amazon Gift Card',
          type: RedemptionType.amazonGiftCard,
          coinCost: AppConstants.giftCard5Value,
          dollarValue: 5.0,
        ),
        RedemptionOption(
          id: 'amazon_10',
          name: 'Amazon Gift Card',
          description: '\$10 Amazon Gift Card',
          type: RedemptionType.amazonGiftCard,
          coinCost: AppConstants.giftCard10Value,
          dollarValue: 10.0,
        ),
        RedemptionOption(
          id: 'amazon_25',
          name: 'Amazon Gift Card',
          description: '\$25 Amazon Gift Card',
          type: RedemptionType.amazonGiftCard,
          coinCost: AppConstants.giftCard25Value,
          dollarValue: 25.0,
        ),
        RedemptionOption(
          id: 'paypal_5',
          name: 'PayPal',
          description: '\$5 PayPal Cash',
          type: RedemptionType.paypal,
          coinCost: AppConstants.giftCard5Value,
          dollarValue: 5.0,
        ),
        RedemptionOption(
          id: 'paypal_10',
          name: 'PayPal',
          description: '\$10 PayPal Cash',
          type: RedemptionType.paypal,
          coinCost: AppConstants.giftCard10Value,
          dollarValue: 10.0,
        ),
        RedemptionOption(
          id: 'paypal_25',
          name: 'PayPal',
          description: '\$25 PayPal Cash',
          type: RedemptionType.paypal,
          coinCost: AppConstants.giftCard25Value,
          dollarValue: 25.0,
        ),
        RedemptionOption(
          id: 'paypal_50',
          name: 'PayPal',
          description: '\$50 PayPal Cash',
          type: RedemptionType.paypal,
          coinCost: AppConstants.giftCard50Value,
          dollarValue: 50.0,
        ),
        RedemptionOption(
          id: 'google_5',
          name: 'Google Play',
          description: '\$5 Google Play Credit',
          type: RedemptionType.googlePlay,
          coinCost: AppConstants.giftCard5Value,
          dollarValue: 5.0,
        ),
        RedemptionOption(
          id: 'google_10',
          name: 'Google Play',
          description: '\$10 Google Play Credit',
          type: RedemptionType.googlePlay,
          coinCost: AppConstants.giftCard10Value,
          dollarValue: 10.0,
        ),
        RedemptionOption(
          id: 'apple_5',
          name: 'Apple Store',
          description: '\$5 App Store Credit',
          type: RedemptionType.appleStore,
          coinCost: AppConstants.giftCard5Value,
          dollarValue: 5.0,
        ),
        RedemptionOption(
          id: 'apple_10',
          name: 'Apple Store',
          description: '\$10 App Store Credit',
          type: RedemptionType.appleStore,
          coinCost: AppConstants.giftCard10Value,
          dollarValue: 10.0,
        ),
        RedemptionOption(
          id: 'visa_10',
          name: 'Visa Prepaid',
          description: '\$10 Visa Prepaid Card',
          type: RedemptionType.visa,
          coinCost: AppConstants.giftCard10Value,
          dollarValue: 10.0,
        ),
        RedemptionOption(
          id: 'visa_25',
          name: 'Visa Prepaid',
          description: '\$25 Visa Prepaid Card',
          type: RedemptionType.visa,
          coinCost: AppConstants.giftCard25Value,
          dollarValue: 25.0,
        ),
      ];

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load redemption options';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Redemption?> redeemOption(RedemptionOption option) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock gift card code
      final code = _generateMockCode(option.type);

      final redemption = Redemption(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        option: option,
        coinSpent: option.coinCost,
        status: RedemptionStatus.completed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        code: code,
      );

      _redemptions.insert(0, redemption);

      _isProcessing = false;
      notifyListeners();
      return redemption;
    } catch (e) {
      _errorMessage = 'Redemption failed. Please try again.';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  String _generateMockCode(RedemptionType type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = timestamp.substring(timestamp.length - 8);

    switch (type) {
      case RedemptionType.amazonGiftCard:
        return 'AMZN-$suffix-GIFT';
      case RedemptionType.paypal:
        return 'PYPL-$suffix-CASH';
      case RedemptionType.googlePlay:
        return 'GPLY-$suffix-CRDT';
      case RedemptionType.appleStore:
        return 'APPL-$suffix-CRDT';
      case RedemptionType.visa:
        return 'VISA-$suffix-CARD';
    }
  }

  List<RedemptionOption> getOptionsByType(RedemptionType type) {
    return _options.where((o) => o.type == type).toList();
  }

  List<RedemptionOption> getAffordableOptions(int userCoins) {
    return _options.where((o) => o.coinCost <= userCoins).toList();
  }

  String getTypeLabel(RedemptionType type) {
    switch (type) {
      case RedemptionType.amazonGiftCard:
        return 'Amazon';
      case RedemptionType.paypal:
        return 'PayPal';
      case RedemptionType.googlePlay:
        return 'Google Play';
      case RedemptionType.appleStore:
        return 'Apple Store';
      case RedemptionType.visa:
        return 'Visa Prepaid';
    }
  }

  IconData getTypeIcon(RedemptionType type) {
    switch (type) {
      case RedemptionType.amazonGiftCard:
        return Icons.shopping_bag;
      case RedemptionType.paypal:
        return Icons.account_balance_wallet;
      case RedemptionType.googlePlay:
        return Icons.play_arrow;
      case RedemptionType.appleStore:
        return Icons.apple;
      case RedemptionType.visa:
        return Icons.credit_card;
    }
  }

  Color getTypeColor(RedemptionType type) {
    switch (type) {
      case RedemptionType.amazonGiftCard:
        return const Color(0xFFFF9900);
      case RedemptionType.paypal:
        return const Color(0xFF003087);
      case RedemptionType.googlePlay:
        return const Color(0xFF34A853);
      case RedemptionType.appleStore:
        return const Color(0xFF000000);
      case RedemptionType.visa:
        return const Color(0xFF1A1F71);
    }
  }
}

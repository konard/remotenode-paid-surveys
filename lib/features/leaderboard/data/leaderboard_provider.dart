import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class LeaderboardEntry {
  final String rank;
  final String name;
  final String avatarUrl;
  final int coins;
  final bool isCurrentUser;
  final bool isFriend;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.coins,
    this.isCurrentUser = false,
    this.isFriend = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
      'name': name,
      'avatarUrl': avatarUrl,
      'coins': coins,
      'isCurrentUser': isCurrentUser,
      'isFriend': isFriend,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      rank: map['rank'],
      name: map['name'],
      avatarUrl: map['avatarUrl'],
      coins: map['coins'],
      isCurrentUser: map['isCurrentUser'] ?? false,
      isFriend: map['isFriend'] ?? false,
    );
  }
}

enum LeaderboardType { global, friends, weekly }

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> _globalLeaderboard = [];
  List<LeaderboardEntry> _friendsLeaderboard = [];
  List<LeaderboardEntry> _weeklyLeaderboard = [];
  LeaderboardEntry? _currentUserEntry;
  bool _isLoading = false;
  String? _errorMessage;
  LeaderboardType _currentType = LeaderboardType.global;

  List<LeaderboardEntry> get globalLeaderboard => _globalLeaderboard;
  List<LeaderboardEntry> get friendsLeaderboard => _friendsLeaderboard;
  List<LeaderboardEntry> get weeklyLeaderboard => _weeklyLeaderboard;
  LeaderboardEntry? get currentUserEntry => _currentUserEntry;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LeaderboardType get currentType => _currentType;

  List<LeaderboardEntry> get currentLeaderboard {
    switch (_currentType) {
      case LeaderboardType.global:
        return _globalLeaderboard;
      case LeaderboardType.friends:
        return _friendsLeaderboard;
      case LeaderboardType.weekly:
        return _weeklyLeaderboard;
    }
  }

  void setLeaderboardType(LeaderboardType type) {
    _currentType = type;
    notifyListeners();
  }

  Future<void> loadLeaderboards() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check cache first
      if (StorageService.isLeaderboardCacheValid()) {
        final cached = StorageService.getCachedLeaderboard();
        if (cached != null) {
          _globalLeaderboard = cached.map((e) => LeaderboardEntry.fromMap(e)).toList();
        }
      }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      _globalLeaderboard = _getMockGlobalLeaderboard();
      _friendsLeaderboard = _getMockFriendsLeaderboard();
      _weeklyLeaderboard = _getMockWeeklyLeaderboard();
      _currentUserEntry = _globalLeaderboard.firstWhere(
        (e) => e.isCurrentUser,
        orElse: () => LeaderboardEntry(
          rank: '42',
          name: 'You',
          avatarUrl: '',
          coins: StorageService.getLifetimeCoins(),
          isCurrentUser: true,
        ),
      );

      // Cache the results
      await StorageService.cacheLeaderboard(
        _globalLeaderboard.map((e) => e.toMap()).toList(),
      );

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load leaderboard';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadLeaderboards();
  }

  List<LeaderboardEntry> _getMockGlobalLeaderboard() {
    final userCoins = StorageService.getLifetimeCoins();
    final userName = StorageService.getUserName() ?? 'You';

    final entries = <LeaderboardEntry>[
      LeaderboardEntry(rank: '1', name: 'SurveyKing', avatarUrl: '', coins: 28450),
      LeaderboardEntry(rank: '2', name: 'QuizMaster', avatarUrl: '', coins: 25320),
      LeaderboardEntry(rank: '3', name: 'OpinionPro', avatarUrl: '', coins: 22890),
      LeaderboardEntry(rank: '4', name: 'DataHunter', avatarUrl: '', coins: 19750),
      LeaderboardEntry(rank: '5', name: 'RewardChaser', avatarUrl: '', coins: 18200),
      LeaderboardEntry(rank: '6', name: 'PollExpert', avatarUrl: '', coins: 16890),
      LeaderboardEntry(rank: '7', name: 'SurveyNinja', avatarUrl: '', coins: 15450),
      LeaderboardEntry(rank: '8', name: 'CoinCollector', avatarUrl: '', coins: 14320),
      LeaderboardEntry(rank: '9', name: 'VoiceOfReason', avatarUrl: '', coins: 13100),
      LeaderboardEntry(rank: '10', name: 'FeedbackFan', avatarUrl: '', coins: 12500),
      LeaderboardEntry(rank: '11', name: 'ResearchPro', avatarUrl: '', coins: 11800),
      LeaderboardEntry(rank: '12', name: 'QuickResponder', avatarUrl: '', coins: 10950),
      LeaderboardEntry(rank: '13', name: 'DataDriven', avatarUrl: '', coins: 10200),
      LeaderboardEntry(rank: '14', name: 'SurveyWizard', avatarUrl: '', coins: 9850),
      LeaderboardEntry(rank: '15', name: 'OpinionMaker', avatarUrl: '', coins: 9400),
    ];

    // Insert current user at appropriate position
    int userRank = 42;
    for (int i = 0; i < entries.length; i++) {
      if (userCoins > entries[i].coins) {
        userRank = i + 1;
        break;
      }
    }

    // Add current user if not in top 15
    if (userRank > 15) {
      entries.add(LeaderboardEntry(
        rank: userRank.toString(),
        name: userName,
        avatarUrl: '',
        coins: userCoins,
        isCurrentUser: true,
      ));
    } else {
      entries.insert(
        userRank - 1,
        LeaderboardEntry(
          rank: userRank.toString(),
          name: userName,
          avatarUrl: '',
          coins: userCoins,
          isCurrentUser: true,
        ),
      );
      // Update ranks
      for (int i = userRank; i < entries.length; i++) {
        final entry = entries[i];
        entries[i] = LeaderboardEntry(
          rank: (i + 1).toString(),
          name: entry.name,
          avatarUrl: entry.avatarUrl,
          coins: entry.coins,
          isCurrentUser: entry.isCurrentUser,
          isFriend: entry.isFriend,
        );
      }
    }

    return entries;
  }

  List<LeaderboardEntry> _getMockFriendsLeaderboard() {
    final userCoins = StorageService.getLifetimeCoins();
    final userName = StorageService.getUserName() ?? 'You';

    return [
      LeaderboardEntry(rank: '1', name: 'Alex M.', avatarUrl: '', coins: 5420, isFriend: true),
      LeaderboardEntry(rank: '2', name: 'Sarah K.', avatarUrl: '', coins: 4850, isFriend: true),
      LeaderboardEntry(rank: '3', name: 'Mike R.', avatarUrl: '', coins: 3920, isFriend: true),
      LeaderboardEntry(
        rank: '4',
        name: userName,
        avatarUrl: '',
        coins: userCoins,
        isCurrentUser: true,
      ),
      LeaderboardEntry(rank: '5', name: 'Emily T.', avatarUrl: '', coins: 2100, isFriend: true),
      LeaderboardEntry(rank: '6', name: 'David L.', avatarUrl: '', coins: 1850, isFriend: true),
      LeaderboardEntry(rank: '7', name: 'Lisa W.', avatarUrl: '', coins: 1420, isFriend: true),
      LeaderboardEntry(rank: '8', name: 'Tom H.', avatarUrl: '', coins: 980, isFriend: true),
    ];
  }

  List<LeaderboardEntry> _getMockWeeklyLeaderboard() {
    final userCoins = (StorageService.getLifetimeCoins() * 0.15).round();
    final userName = StorageService.getUserName() ?? 'You';

    return [
      LeaderboardEntry(rank: '1', name: 'WeeklyChamp', avatarUrl: '', coins: 1250),
      LeaderboardEntry(rank: '2', name: 'ActiveUser', avatarUrl: '', coins: 980),
      LeaderboardEntry(rank: '3', name: 'SurveyFan', avatarUrl: '', coins: 850),
      LeaderboardEntry(rank: '4', name: 'QuickEarner', avatarUrl: '', coins: 720),
      LeaderboardEntry(rank: '5', name: 'DailyGrind', avatarUrl: '', coins: 650),
      LeaderboardEntry(
        rank: '6',
        name: userName,
        avatarUrl: '',
        coins: userCoins,
        isCurrentUser: true,
      ),
      LeaderboardEntry(rank: '7', name: 'NewRiser', avatarUrl: '', coins: 420),
      LeaderboardEntry(rank: '8', name: 'Consistent', avatarUrl: '', coins: 380),
      LeaderboardEntry(rank: '9', name: 'Dedicated', avatarUrl: '', coins: 320),
      LeaderboardEntry(rank: '10', name: 'Motivated', avatarUrl: '', coins: 280),
    ];
  }
}

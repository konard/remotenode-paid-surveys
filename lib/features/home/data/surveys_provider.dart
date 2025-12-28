import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

enum QuestionType { multipleChoice, text, rating, yesNo }

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String>? options;
  final int? minRating;
  final int? maxRating;
  final bool required;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.minRating,
    this.maxRating,
    this.required = true,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
      type: QuestionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      minRating: map['minRating'],
      maxRating: map['maxRating'],
      required: map['required'] ?? true,
    );
  }
}

class Survey {
  final String id;
  final String title;
  final String description;
  final String category;
  final int coinReward;
  final int estimatedMinutes;
  final List<Question> questions;
  final String? imageUrl;
  final bool featured;
  final DateTime? expiresAt;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.coinReward,
    required this.estimatedMinutes,
    required this.questions,
    this.imageUrl,
    this.featured = false,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory Survey.fromMap(Map<String, dynamic> map) {
    return Survey(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      coinReward: map['coinReward'],
      estimatedMinutes: map['estimatedMinutes'],
      questions: (map['questions'] as List)
          .map((q) => Question.fromMap(q))
          .toList(),
      imageUrl: map['imageUrl'],
      featured: map['featured'] ?? false,
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'])
          : null,
    );
  }
}

class SurveysProvider extends ChangeNotifier {
  List<Survey> _surveys = [];
  List<String> _completedSurveyIds = [];
  bool _isLoading = false;
  String? _errorMessage;
  Survey? _currentSurvey;
  Map<String, dynamic> _currentAnswers = {};
  int _currentQuestionIndex = 0;

  List<Survey> get surveys => _surveys;
  List<Survey> get availableSurveys =>
      _surveys.where((s) => !_completedSurveyIds.contains(s.id) && !s.isExpired).toList();
  List<Survey> get featuredSurveys =>
      availableSurveys.where((s) => s.featured).toList();
  List<String> get completedSurveyIds => _completedSurveyIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Survey? get currentSurvey => _currentSurvey;
  Map<String, dynamic> get currentAnswers => _currentAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _currentSurvey?.questions.length ?? 0;
  Question? get currentQuestion => _currentSurvey != null &&
          _currentQuestionIndex < _currentSurvey!.questions.length
      ? _currentSurvey!.questions[_currentQuestionIndex]
      : null;

  Future<void> loadSurveys() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _surveys = _getMockSurveys();
      _completedSurveyIds = StorageService.getCompletedSurveys();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load surveys';
    }

    _isLoading = false;
    notifyListeners();
  }

  void startSurvey(Survey survey) {
    _currentSurvey = survey;
    _currentAnswers = {};
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  void setAnswer(String questionId, dynamic answer) {
    _currentAnswers[questionId] = answer;
    notifyListeners();
  }

  bool canProceed() {
    if (_currentSurvey == null) return false;
    final question = currentQuestion;
    if (question == null) return false;
    if (!question.required) return true;
    return _currentAnswers.containsKey(question.id);
  }

  void nextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<bool> completeSurvey() async {
    if (_currentSurvey == null) return false;

    try {
      await StorageService.saveCompletedSurvey(_currentSurvey!.id);
      _completedSurveyIds.add(_currentSurvey!.id);

      final survey = _currentSurvey!;
      _currentSurvey = null;
      _currentAnswers = {};
      _currentQuestionIndex = 0;

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void cancelSurvey() {
    _currentSurvey = null;
    _currentAnswers = {};
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  int get completedSurveysCount => _completedSurveyIds.length;

  List<Survey> getSurveysByCategory(String category) {
    return availableSurveys.where((s) => s.category == category).toList();
  }

  List<String> get categories {
    return _surveys.map((s) => s.category).toSet().toList();
  }

  List<Survey> _getMockSurveys() {
    return [
      // Survey 1: Consumer Preferences
      Survey(
        id: 'survey_001',
        title: 'Consumer Shopping Habits',
        description: 'Help brands understand your shopping preferences',
        category: 'Consumer Research',
        coinReward: 75,
        estimatedMinutes: 5,
        featured: true,
        questions: [
          Question(
            id: 'q1_1',
            text: 'How often do you shop online?',
            type: QuestionType.multipleChoice,
            options: ['Daily', 'Weekly', 'Monthly', 'Rarely', 'Never'],
          ),
          Question(
            id: 'q1_2',
            text: 'What factors influence your purchasing decisions the most?',
            type: QuestionType.multipleChoice,
            options: ['Price', 'Brand', 'Reviews', 'Recommendations', 'Quality'],
          ),
          Question(
            id: 'q1_3',
            text: 'Rate your overall online shopping experience',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
          Question(
            id: 'q1_4',
            text: 'What improvements would you like to see in online shopping?',
            type: QuestionType.text,
            required: false,
          ),
        ],
      ),

      // Survey 2: Mobile Apps Usage
      Survey(
        id: 'survey_002',
        title: 'Mobile App Usage Survey',
        description: 'Share your mobile app habits and preferences',
        category: 'Technology',
        coinReward: 50,
        estimatedMinutes: 3,
        questions: [
          Question(
            id: 'q2_1',
            text: 'How many hours do you spend on mobile apps daily?',
            type: QuestionType.multipleChoice,
            options: ['Less than 1 hour', '1-3 hours', '3-5 hours', 'More than 5 hours'],
          ),
          Question(
            id: 'q2_2',
            text: 'What type of apps do you use most?',
            type: QuestionType.multipleChoice,
            options: ['Social Media', 'Games', 'Productivity', 'Entertainment', 'Shopping'],
          ),
          Question(
            id: 'q2_3',
            text: 'Do you pay for premium app features?',
            type: QuestionType.yesNo,
          ),
        ],
      ),

      // Survey 3: Food Preferences
      Survey(
        id: 'survey_003',
        title: 'Food & Dining Preferences',
        description: 'Tell us about your food choices and dining habits',
        category: 'Lifestyle',
        coinReward: 60,
        estimatedMinutes: 4,
        featured: true,
        questions: [
          Question(
            id: 'q3_1',
            text: 'How often do you eat out or order food delivery?',
            type: QuestionType.multipleChoice,
            options: ['Daily', '2-3 times a week', 'Once a week', 'Rarely'],
          ),
          Question(
            id: 'q3_2',
            text: 'What type of cuisine do you prefer?',
            type: QuestionType.multipleChoice,
            options: ['Italian', 'Asian', 'Mexican', 'American', 'Mediterranean'],
          ),
          Question(
            id: 'q3_3',
            text: 'Rate your satisfaction with food delivery services',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
          Question(
            id: 'q3_4',
            text: 'Do you follow any dietary restrictions?',
            type: QuestionType.yesNo,
          ),
        ],
      ),

      // Survey 4: Streaming Services
      Survey(
        id: 'survey_004',
        title: 'Streaming Services Feedback',
        description: 'Help improve your favorite streaming platforms',
        category: 'Entertainment',
        coinReward: 80,
        estimatedMinutes: 6,
        questions: [
          Question(
            id: 'q4_1',
            text: 'Which streaming services do you subscribe to?',
            type: QuestionType.multipleChoice,
            options: ['Netflix', 'Amazon Prime', 'Disney+', 'Hulu', 'HBO Max'],
          ),
          Question(
            id: 'q4_2',
            text: 'How many hours do you spend watching streaming content weekly?',
            type: QuestionType.multipleChoice,
            options: ['Less than 5', '5-10', '10-20', 'More than 20'],
          ),
          Question(
            id: 'q4_3',
            text: 'What genre do you watch most?',
            type: QuestionType.multipleChoice,
            options: ['Drama', 'Comedy', 'Action', 'Documentary', 'Sci-Fi'],
          ),
          Question(
            id: 'q4_4',
            text: 'Rate the content quality of your favorite streaming service',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
          Question(
            id: 'q4_5',
            text: 'What features would you like to see added?',
            type: QuestionType.text,
            required: false,
          ),
        ],
      ),

      // Survey 5: Fitness & Wellness
      Survey(
        id: 'survey_005',
        title: 'Fitness & Wellness Habits',
        description: 'Share your health and fitness routines',
        category: 'Health',
        coinReward: 70,
        estimatedMinutes: 5,
        questions: [
          Question(
            id: 'q5_1',
            text: 'How often do you exercise?',
            type: QuestionType.multipleChoice,
            options: ['Daily', '3-5 times a week', '1-2 times a week', 'Rarely', 'Never'],
          ),
          Question(
            id: 'q5_2',
            text: 'What type of exercise do you prefer?',
            type: QuestionType.multipleChoice,
            options: ['Running', 'Gym', 'Yoga', 'Sports', 'Home workouts'],
          ),
          Question(
            id: 'q5_3',
            text: 'Do you use fitness apps or wearables?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q5_4',
            text: 'Rate your overall health and wellness',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 6: Travel Preferences
      Survey(
        id: 'survey_006',
        title: 'Travel Preferences Survey',
        description: 'Tell us about your travel habits and dream destinations',
        category: 'Travel',
        coinReward: 90,
        estimatedMinutes: 7,
        featured: true,
        questions: [
          Question(
            id: 'q6_1',
            text: 'How often do you travel for leisure?',
            type: QuestionType.multipleChoice,
            options: ['Multiple times a year', 'Once a year', 'Every few years', 'Rarely'],
          ),
          Question(
            id: 'q6_2',
            text: 'What type of vacation do you prefer?',
            type: QuestionType.multipleChoice,
            options: ['Beach', 'Adventure', 'Cultural', 'City', 'Nature'],
          ),
          Question(
            id: 'q6_3',
            text: 'How do you typically book your trips?',
            type: QuestionType.multipleChoice,
            options: ['Travel agency', 'Online booking', 'Travel apps', 'Direct booking'],
          ),
          Question(
            id: 'q6_4',
            text: 'What is your average travel budget per trip?',
            type: QuestionType.multipleChoice,
            options: ['Under \$500', '\$500-\$1000', '\$1000-\$2500', 'Over \$2500'],
          ),
          Question(
            id: 'q6_5',
            text: 'Rate your overall travel experiences',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 7: Social Media Usage
      Survey(
        id: 'survey_007',
        title: 'Social Media Habits',
        description: 'Help us understand social media usage patterns',
        category: 'Technology',
        coinReward: 55,
        estimatedMinutes: 4,
        questions: [
          Question(
            id: 'q7_1',
            text: 'Which social media platforms do you use most?',
            type: QuestionType.multipleChoice,
            options: ['Instagram', 'TikTok', 'Facebook', 'Twitter/X', 'LinkedIn'],
          ),
          Question(
            id: 'q7_2',
            text: 'How much time do you spend on social media daily?',
            type: QuestionType.multipleChoice,
            options: ['Less than 1 hour', '1-2 hours', '2-4 hours', 'More than 4 hours'],
          ),
          Question(
            id: 'q7_3',
            text: 'Do you follow influencers or content creators?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q7_4',
            text: 'Have you made a purchase based on social media ads?',
            type: QuestionType.yesNo,
          ),
        ],
      ),

      // Survey 8: Financial Habits
      Survey(
        id: 'survey_008',
        title: 'Financial Habits Survey',
        description: 'Share your saving and spending patterns',
        category: 'Finance',
        coinReward: 100,
        estimatedMinutes: 8,
        questions: [
          Question(
            id: 'q8_1',
            text: 'Do you have a monthly budget?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q8_2',
            text: 'What percentage of income do you save?',
            type: QuestionType.multipleChoice,
            options: ['0-10%', '10-20%', '20-30%', 'More than 30%'],
          ),
          Question(
            id: 'q8_3',
            text: 'What is your preferred payment method?',
            type: QuestionType.multipleChoice,
            options: ['Credit card', 'Debit card', 'Cash', 'Digital wallets', 'Buy now pay later'],
          ),
          Question(
            id: 'q8_4',
            text: 'Do you invest in stocks or cryptocurrency?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q8_5',
            text: 'Rate your financial literacy',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 9: Work From Home
      Survey(
        id: 'survey_009',
        title: 'Remote Work Experience',
        description: 'Share your work from home experience',
        category: 'Work',
        coinReward: 65,
        estimatedMinutes: 5,
        questions: [
          Question(
            id: 'q9_1',
            text: 'How often do you work from home?',
            type: QuestionType.multipleChoice,
            options: ['Full-time', 'Hybrid', 'Rarely', 'Never'],
          ),
          Question(
            id: 'q9_2',
            text: 'What is your biggest challenge working from home?',
            type: QuestionType.multipleChoice,
            options: ['Distractions', 'Communication', 'Work-life balance', 'Technology', 'Loneliness'],
          ),
          Question(
            id: 'q9_3',
            text: 'Do you have a dedicated home office?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q9_4',
            text: 'Rate your remote work productivity',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 10: Gaming Preferences
      Survey(
        id: 'survey_010',
        title: 'Gaming Preferences Survey',
        description: 'Tell us about your gaming habits',
        category: 'Entertainment',
        coinReward: 85,
        estimatedMinutes: 6,
        questions: [
          Question(
            id: 'q10_1',
            text: 'What gaming platform do you prefer?',
            type: QuestionType.multipleChoice,
            options: ['PC', 'PlayStation', 'Xbox', 'Nintendo Switch', 'Mobile'],
          ),
          Question(
            id: 'q10_2',
            text: 'How many hours do you game per week?',
            type: QuestionType.multipleChoice,
            options: ['Less than 5', '5-10', '10-20', 'More than 20'],
          ),
          Question(
            id: 'q10_3',
            text: 'What game genre do you prefer?',
            type: QuestionType.multipleChoice,
            options: ['Action', 'RPG', 'Sports', 'Strategy', 'Puzzle'],
          ),
          Question(
            id: 'q10_4',
            text: 'Do you make in-game purchases?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q10_5',
            text: 'Rate your overall gaming satisfaction',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 11: Electric Vehicles
      Survey(
        id: 'survey_011',
        title: 'Electric Vehicle Interest',
        description: 'Share your thoughts on electric vehicles',
        category: 'Automotive',
        coinReward: 70,
        estimatedMinutes: 5,
        questions: [
          Question(
            id: 'q11_1',
            text: 'Do you own an electric vehicle?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q11_2',
            text: 'Would you consider buying an electric vehicle?',
            type: QuestionType.multipleChoice,
            options: ['Definitely', 'Probably', 'Maybe', 'Unlikely', 'Never'],
          ),
          Question(
            id: 'q11_3',
            text: 'What is your main concern about EVs?',
            type: QuestionType.multipleChoice,
            options: ['Price', 'Range', 'Charging', 'Performance', 'Environmental'],
          ),
          Question(
            id: 'q11_4',
            text: 'Rate your interest in sustainable transportation',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 12: Smart Home
      Survey(
        id: 'survey_012',
        title: 'Smart Home Technology',
        description: 'Tell us about your smart home setup',
        category: 'Technology',
        coinReward: 60,
        estimatedMinutes: 4,
        questions: [
          Question(
            id: 'q12_1',
            text: 'Do you use smart home devices?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q12_2',
            text: 'Which smart home devices do you own?',
            type: QuestionType.multipleChoice,
            options: ['Smart speaker', 'Smart thermostat', 'Smart lights', 'Security cameras', 'None'],
          ),
          Question(
            id: 'q12_3',
            text: 'What is your preferred smart home platform?',
            type: QuestionType.multipleChoice,
            options: ['Amazon Alexa', 'Google Home', 'Apple HomeKit', 'Samsung SmartThings', 'None'],
          ),
          Question(
            id: 'q12_4',
            text: 'Rate your smart home experience',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 13: Pet Ownership
      Survey(
        id: 'survey_013',
        title: 'Pet Ownership Survey',
        description: 'Share your experience as a pet owner',
        category: 'Lifestyle',
        coinReward: 55,
        estimatedMinutes: 4,
        questions: [
          Question(
            id: 'q13_1',
            text: 'Do you own a pet?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q13_2',
            text: 'What type of pet do you have?',
            type: QuestionType.multipleChoice,
            options: ['Dog', 'Cat', 'Bird', 'Fish', 'Other'],
          ),
          Question(
            id: 'q13_3',
            text: 'How much do you spend on pet care monthly?',
            type: QuestionType.multipleChoice,
            options: ['Under \$50', '\$50-\$100', '\$100-\$200', 'Over \$200'],
          ),
          Question(
            id: 'q13_4',
            text: 'Rate your overall pet ownership experience',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 14: Coffee & Beverages
      Survey(
        id: 'survey_014',
        title: 'Coffee & Beverage Habits',
        description: 'Tell us about your favorite drinks',
        category: 'Food & Drink',
        coinReward: 45,
        estimatedMinutes: 3,
        questions: [
          Question(
            id: 'q14_1',
            text: 'How many cups of coffee do you drink daily?',
            type: QuestionType.multipleChoice,
            options: ['None', '1-2', '3-4', 'More than 4'],
          ),
          Question(
            id: 'q14_2',
            text: 'Where do you usually buy coffee?',
            type: QuestionType.multipleChoice,
            options: ['Home brew', 'Starbucks', 'Local cafe', 'Work', 'Other chains'],
          ),
          Question(
            id: 'q14_3',
            text: 'What is your favorite coffee drink?',
            type: QuestionType.multipleChoice,
            options: ['Espresso', 'Latte', 'Cappuccino', 'Cold brew', 'Black coffee'],
          ),
        ],
      ),

      // Survey 15: Education Preferences
      Survey(
        id: 'survey_015',
        title: 'Online Learning Survey',
        description: 'Share your online education experiences',
        category: 'Education',
        coinReward: 75,
        estimatedMinutes: 5,
        questions: [
          Question(
            id: 'q15_1',
            text: 'Have you taken online courses?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q15_2',
            text: 'Which online learning platform do you prefer?',
            type: QuestionType.multipleChoice,
            options: ['Coursera', 'Udemy', 'LinkedIn Learning', 'Skillshare', 'YouTube'],
          ),
          Question(
            id: 'q15_3',
            text: 'What topics are you interested in learning?',
            type: QuestionType.multipleChoice,
            options: ['Technology', 'Business', 'Creative', 'Languages', 'Personal development'],
          ),
          Question(
            id: 'q15_4',
            text: 'Rate the quality of online education',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 16: Subscription Services
      Survey(
        id: 'survey_016',
        title: 'Subscription Services Survey',
        description: 'Tell us about your subscriptions',
        category: 'Consumer Research',
        coinReward: 65,
        estimatedMinutes: 5,
        questions: [
          Question(
            id: 'q16_1',
            text: 'How many subscription services do you pay for?',
            type: QuestionType.multipleChoice,
            options: ['None', '1-3', '4-6', 'More than 6'],
          ),
          Question(
            id: 'q16_2',
            text: 'What type of subscriptions do you have?',
            type: QuestionType.multipleChoice,
            options: ['Streaming', 'Software', 'Food delivery', 'Beauty boxes', 'News/magazines'],
          ),
          Question(
            id: 'q16_3',
            text: 'Do you track your subscription spending?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q16_4',
            text: 'Have you cancelled subscriptions in the past year?',
            type: QuestionType.yesNo,
          ),
        ],
      ),

      // Survey 17: Fashion & Style
      Survey(
        id: 'survey_017',
        title: 'Fashion & Style Survey',
        description: 'Share your fashion preferences',
        category: 'Lifestyle',
        coinReward: 50,
        estimatedMinutes: 4,
        questions: [
          Question(
            id: 'q17_1',
            text: 'How often do you shop for clothes?',
            type: QuestionType.multipleChoice,
            options: ['Weekly', 'Monthly', 'Seasonally', 'Rarely'],
          ),
          Question(
            id: 'q17_2',
            text: 'Where do you prefer to shop for clothes?',
            type: QuestionType.multipleChoice,
            options: ['Online', 'Department stores', 'Boutiques', 'Fast fashion', 'Thrift stores'],
          ),
          Question(
            id: 'q17_3',
            text: 'What influences your fashion choices?',
            type: QuestionType.multipleChoice,
            options: ['Social media', 'Friends', 'Magazines', 'Personal style', 'Celebrities'],
          ),
        ],
      ),

      // Survey 18: Sustainability
      Survey(
        id: 'survey_018',
        title: 'Sustainability Habits Survey',
        description: 'Tell us about your eco-friendly practices',
        category: 'Environment',
        coinReward: 80,
        estimatedMinutes: 6,
        featured: true,
        questions: [
          Question(
            id: 'q18_1',
            text: 'Do you recycle regularly?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q18_2',
            text: 'What sustainable practices do you follow?',
            type: QuestionType.multipleChoice,
            options: ['Reduce plastic', 'Energy saving', 'Public transport', 'Plant-based diet', 'Composting'],
          ),
          Question(
            id: 'q18_3',
            text: 'Are you willing to pay more for eco-friendly products?',
            type: QuestionType.multipleChoice,
            options: ['Yes, always', 'Sometimes', 'Rarely', 'No'],
          ),
          Question(
            id: 'q18_4',
            text: 'Rate your commitment to sustainability',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 19: Mental Health
      Survey(
        id: 'survey_019',
        title: 'Mental Wellness Survey',
        description: 'Share your mental health practices',
        category: 'Health',
        coinReward: 85,
        estimatedMinutes: 6,
        questions: [
          Question(
            id: 'q19_1',
            text: 'How would you rate your current stress level?',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
          Question(
            id: 'q19_2',
            text: 'What do you do to manage stress?',
            type: QuestionType.multipleChoice,
            options: ['Exercise', 'Meditation', 'Hobbies', 'Therapy', 'Social activities'],
          ),
          Question(
            id: 'q19_3',
            text: 'Do you use any mental health apps?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q19_4',
            text: 'How important is work-life balance to you?',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 20: Parenting
      Survey(
        id: 'survey_020',
        title: 'Parenting Survey',
        description: 'Share your parenting experiences',
        category: 'Family',
        coinReward: 95,
        estimatedMinutes: 7,
        questions: [
          Question(
            id: 'q20_1',
            text: 'How many children do you have?',
            type: QuestionType.multipleChoice,
            options: ['None', '1', '2', '3+'],
          ),
          Question(
            id: 'q20_2',
            text: 'What is your biggest parenting challenge?',
            type: QuestionType.multipleChoice,
            options: ['Time management', 'Education', 'Health', 'Discipline', 'Finance'],
          ),
          Question(
            id: 'q20_3',
            text: 'How much screen time do your children have daily?',
            type: QuestionType.multipleChoice,
            options: ['Less than 1 hour', '1-2 hours', '2-4 hours', 'More than 4 hours'],
          ),
          Question(
            id: 'q20_4',
            text: 'Do you use parenting apps or resources?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q20_5',
            text: 'Rate your overall parenting experience',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),

      // Survey 21: News Consumption
      Survey(
        id: 'survey_021',
        title: 'News & Media Consumption',
        description: 'Tell us how you stay informed',
        category: 'Media',
        coinReward: 55,
        estimatedMinutes: 4,
        questions: [
          Question(
            id: 'q21_1',
            text: 'How do you primarily consume news?',
            type: QuestionType.multipleChoice,
            options: ['Social media', 'News apps', 'TV', 'Newspapers', 'Podcasts'],
          ),
          Question(
            id: 'q21_2',
            text: 'How often do you check the news?',
            type: QuestionType.multipleChoice,
            options: ['Multiple times daily', 'Once daily', 'Few times a week', 'Rarely'],
          ),
          Question(
            id: 'q21_3',
            text: 'Do you pay for news subscriptions?',
            type: QuestionType.yesNo,
          ),
        ],
      ),

      // Survey 22: Cryptocurrency
      Survey(
        id: 'survey_022',
        title: 'Cryptocurrency Survey',
        description: 'Share your crypto experience',
        category: 'Finance',
        coinReward: 75,
        estimatedMinutes: 5,
        questions: [
          Question(
            id: 'q22_1',
            text: 'Do you own any cryptocurrency?',
            type: QuestionType.yesNo,
          ),
          Question(
            id: 'q22_2',
            text: 'Which cryptocurrencies are you interested in?',
            type: QuestionType.multipleChoice,
            options: ['Bitcoin', 'Ethereum', 'Solana', 'Dogecoin', 'Others'],
          ),
          Question(
            id: 'q22_3',
            text: 'What is your main reason for investing in crypto?',
            type: QuestionType.multipleChoice,
            options: ['Long-term investment', 'Trading', 'Technology interest', 'Diversification', 'FOMO'],
          ),
          Question(
            id: 'q22_4',
            text: 'Rate your understanding of blockchain technology',
            type: QuestionType.rating,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      ),
    ];
  }
}

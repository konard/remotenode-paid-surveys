import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _userId;
  String? _email;
  String? _name;
  bool _isAnonymous = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;
  bool get isAnonymous => _isAnonymous;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthState() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (StorageService.isLoggedIn()) {
      _userId = StorageService.getUserId();
      _email = StorageService.getUserEmail();
      _name = StorageService.getUserName();
      _isAnonymous = StorageService.isAnonymous();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock validation
      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Generate mock user
      _userId = const Uuid().v4();
      _email = email;
      _name = email.split('@').first;
      _isAnonymous = false;

      await StorageService.saveUser(
        id: _userId!,
        email: _email,
        name: _name,
        isAnonymous: false,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock validation
      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      if (name.isEmpty) {
        throw Exception('Name is required');
      }

      // Generate mock user
      _userId = const Uuid().v4();
      _email = email;
      _name = name;
      _isAnonymous = false;

      await StorageService.saveUser(
        id: _userId!,
        email: _email,
        name: _name,
        isAnonymous: false,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate anonymous user
      _userId = const Uuid().v4();
      _email = null;
      _name = 'Guest User';
      _isAnonymous = true;

      await StorageService.saveUser(
        id: _userId!,
        name: _name,
        isAnonymous: true,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await StorageService.logout();

    _userId = null;
    _email = null;
    _name = null;
    _isAnonymous = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile({String? name, String? email}) async {
    try {
      if (name != null) _name = name;
      if (email != null) _email = email;

      await StorageService.saveUser(
        id: _userId!,
        email: _email,
        name: _name,
        isAnonymous: _isAnonymous,
      );

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}

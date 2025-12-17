import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/interfaces/auth_service_interface.dart';

/// ChangeNotifier wrapper for authentication state
/// Allows widgets to rebuild when auth state changes
class AuthProvider extends ChangeNotifier {
  final IAuthService _authService;
  StreamSubscription<User?>? _authSubscription;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({IAuthService? authService})
      : _authService = authService ?? AuthService() {
    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
    // Initialize with current user
    _user = _authService.currentUser;
  }

  // ============ Getters ============

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============ Actions ============

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.login(email, password);

    _setLoading(false);

    if (result.isSuccess) {
      _user = result.user;
      notifyListeners();
      return true;
    } else {
      _error = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    _setLoading(false);

    if (result.isSuccess) {
      _user = result.user;
      notifyListeners();
      return true;
    } else {
      _error = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _clearError();
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ============ Private Helpers ============

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authService.dispose();
    super.dispose();
  }
}

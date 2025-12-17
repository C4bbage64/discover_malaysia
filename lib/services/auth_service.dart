import 'dart:async';
import '../config/app_config.dart';
import '../models/user.dart';
import 'interfaces/auth_service_interface.dart';

export 'interfaces/auth_service_interface.dart' show AuthResult;

/// Authentication service for user login/registration
/// Currently uses local/dummy data; can be swapped to Firebase/API later
class AuthService implements IAuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();

  /// Stream of auth state changes
  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  /// Current logged-in user
  @override
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  @override
  bool get isLoggedIn => _currentUser != null;

  /// Check if current user is admin
  @override
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Login with email and password
  @override
  Future<AuthResult> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find user in dummy data
    final user = _dummyUsers.where((u) => u['email'] == email).firstOrNull;

    if (user == null) {
      return AuthResult.failure('User not found. Please register first.');
    }

    if (user['password'] != password) {
      return AuthResult.failure('Incorrect password.');
    }

    _currentUser = User(
      id: user['id'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
      role: user['role'] as UserRole,
      createdAt: user['createdAt'] as DateTime,
    );

    _authStateController.add(_currentUser);
    return AuthResult.success(_currentUser!);
  }

  /// Register a new user
  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if email already exists
    final exists = _dummyUsers.any((u) => u['email'] == email);
    if (exists) {
      return AuthResult.failure('Email already registered. Please login.');
    }

    // Validate inputs
    if (name.trim().isEmpty) {
      return AuthResult.failure('Name is required.');
    }
    if (!_isValidEmail(email)) {
      return AuthResult.failure('Please enter a valid email address.');
    }
    if (password.length < AppConfig.minPasswordLength) {
      return AuthResult.failure('Password must be at least ${AppConfig.minPasswordLength} characters.');
    }

    // Create new user
    final newUser = {
      'id': 'u${_dummyUsers.length + 1}',
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': UserRole.user,
      'createdAt': DateTime.now(),
    };
    _dummyUsers.add(newUser);

    _currentUser = User(
      id: newUser['id'] as String,
      name: newUser['name'] as String,
      email: newUser['email'] as String,
      role: newUser['role'] as UserRole,
      createdAt: newUser['createdAt'] as DateTime,
    );

    _authStateController.add(_currentUser);
    return AuthResult.success(_currentUser!);
  }

  /// Logout the current user
  @override
  Future<void> logout() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  /// Dispose resources
  @override
  void dispose() {
    _authStateController.close();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // ============ DUMMY DATA ============

  final List<Map<String, dynamic>> _dummyUsers = [
    {
      'id': 'u1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'password123',
      'role': UserRole.user,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 'admin1',
      'name': 'Admin User',
      'email': 'admin@discovermalaysia.com',
      'password': 'admin123',
      'role': UserRole.admin,
      'createdAt': DateTime.now().subtract(const Duration(days: 90)),
    },
  ];
}

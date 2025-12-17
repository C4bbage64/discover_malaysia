import '../../models/user.dart';

/// Result of an authentication operation
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(User user) =>
      AuthResult._(isSuccess: true, user: user);

  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}

/// Abstract interface for authentication operations
/// Allows for easy swapping between mock and real implementations
abstract class IAuthService {
  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Current logged-in user
  User? get currentUser;

  /// Check if user is logged in
  bool get isLoggedIn;

  /// Check if current user is admin
  bool get isAdmin;

  /// Login with email and password
  Future<AuthResult> login(String email, String password);

  /// Register a new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });

  /// Logout the current user
  Future<void> logout();

  /// Dispose resources
  void dispose();
}

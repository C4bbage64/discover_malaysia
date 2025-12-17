import 'package:discover_malaysia/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      // Create a fresh instance for each test
      // Note: In production, you'd want to reset the singleton state
      authService = AuthService();
    });

    group('login', () {
      test('should return success for valid demo user credentials', () async {
        final result = await authService.login(
          'john@example.com',
          'password123',
        );

        expect(result.isSuccess, isTrue);
        expect(result.user, isNotNull);
        expect(result.user!.email, equals('john@example.com'));
        expect(result.user!.name, equals('John Doe'));
      });

      test('should return success for valid admin credentials', () async {
        final result = await authService.login(
          'admin@discovermalaysia.com',
          'admin123',
        );

        expect(result.isSuccess, isTrue);
        expect(result.user, isNotNull);
        expect(result.user!.isAdmin, isTrue);
      });

      test('should return failure for non-existent user', () async {
        final result = await authService.login(
          'nonexistent@example.com',
          'password123',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('not found'));
      });

      test('should return failure for incorrect password', () async {
        final result = await authService.login(
          'john@example.com',
          'wrongpassword',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('Incorrect password'));
      });
    });

    group('register', () {
      test('should create new user with valid data', () async {
        final result = await authService.register(
          name: 'Test User',
          email: 'testuser${DateTime.now().millisecondsSinceEpoch}@example.com',
          password: 'testpass123',
        );

        expect(result.isSuccess, isTrue);
        expect(result.user, isNotNull);
        expect(result.user!.name, equals('Test User'));
      });

      test('should fail for empty name', () async {
        final result = await authService.register(
          name: '',
          email: 'test@example.com',
          password: 'testpass123',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('Name'));
      });

      test('should fail for invalid email', () async {
        final result = await authService.register(
          name: 'Test User',
          email: 'invalid-email',
          password: 'testpass123',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('email'));
      });

      test('should fail for short password', () async {
        final result = await authService.register(
          name: 'Test User',
          email: 'test@example.com',
          password: '12345',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('6 characters'));
      });

      test('should fail for duplicate email', () async {
        final result = await authService.register(
          name: 'Another User',
          email: 'john@example.com', // Already exists
          password: 'testpass123',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('already registered'));
      });
    });

    group('logout', () {
      test('should clear current user after logout', () async {
        // First login
        await authService.login('john@example.com', 'password123');
        expect(authService.isLoggedIn, isTrue);

        // Then logout
        await authService.logout();
        expect(authService.isLoggedIn, isFalse);
        expect(authService.currentUser, isNull);
      });
    });

    group('isAdmin', () {
      test('should return false for regular user', () async {
        await authService.login('john@example.com', 'password123');
        expect(authService.isAdmin, isFalse);
      });

      test('should return true for admin user', () async {
        await authService.login('admin@discovermalaysia.com', 'admin123');
        expect(authService.isAdmin, isTrue);
      });
    });
  });
}

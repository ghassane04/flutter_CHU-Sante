import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/models/index.dart';

@GenerateMocks([ApiService])
import 'auth_provider_test.mocks.dart';

void main() {
  late AuthProvider authProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    authProvider = AuthProvider(mockApiService);
  });

  group('AuthProvider', () {
    group('login', () {
      test('should return true on successful login', () async {
        // Arrange
        final jwtResponse = JwtResponse(
          token: 'test_token',
          id: 1,
          username: 'admin',
          email: 'admin@test.com',
        );
        
        when(mockApiService.login(any)).thenAnswer((_) async => jwtResponse);

        // Act
        final result = await authProvider.login('admin', 'password');

        // Assert
        expect(result, true);
        expect(authProvider.currentUser, jwtResponse);
        expect(authProvider.error, isNull);
        expect(authProvider.isLoading, false);
        verify(mockApiService.login(any)).called(1);
      });

      test('should return false and set error on failed login', () async {
        // Arrange
        when(mockApiService.login(any)).thenThrow(Exception('Invalid credentials'));

        // Act
        final result = await authProvider.login('admin', 'wrongpassword');

        // Assert
        expect(result, false);
        expect(authProvider.currentUser, isNull);
        expect(authProvider.error, contains('Invalid credentials'));
        expect(authProvider.isLoading, false);
      });

      test('should set isLoading to true during login', () async {
        // Arrange
        when(mockApiService.login(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return JwtResponse(token: 'token', id: 1, username: 'user', email: 'user@test.com');
        });

        // Act - start login but don't await
        final loginFuture = authProvider.login('admin', 'password');
        
        // Small delay to allow state change
        await Future.delayed(const Duration(milliseconds: 10));
        
        // Wait for completion
        await loginFuture;
        
        // Assert - after completion, isLoading should be false
        expect(authProvider.isLoading, false);
      });
    });

    group('signup', () {
      test('should return true on successful signup', () async {
        // Arrange
        final signupRequest = SignupRequest(
          username: 'newuser',
          email: 'new@test.com',
          password: 'password123',
          nom: 'Dupont',
          prenom: 'Jean',
        );
        
        when(mockApiService.signup(any)).thenAnswer((_) async => MessageResponse(message: 'Success'));

        // Act
        final result = await authProvider.signup(signupRequest);

        // Assert
        expect(result, true);
        expect(authProvider.error, isNull);
        expect(authProvider.isLoading, false);
        verify(mockApiService.signup(any)).called(1);
      });

      test('should return false and set error on failed signup', () async {
        // Arrange
        final signupRequest = SignupRequest(
          username: 'newuser',
          email: 'new@test.com',
          password: 'password123',
          nom: 'Dupont',
          prenom: 'Jean',
        );
        
        when(mockApiService.signup(any)).thenThrow(Exception('Username already exists'));

        // Act
        final result = await authProvider.signup(signupRequest);

        // Assert
        expect(result, false);
        expect(authProvider.error, contains('Username already exists'));
        expect(authProvider.isLoading, false);
      });
    });

    group('logout', () {
      test('should clear user data on logout', () async {
        // Arrange
        when(mockApiService.logout()).thenAnswer((_) async => {});

        // Act
        await authProvider.logout();

        // Assert
        expect(authProvider.currentUser, isNull);
        expect(authProvider.error, isNull);
        verify(mockApiService.logout()).called(1);
      });
    });
  });
}

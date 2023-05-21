import 'package:test/test.dart';
import 'package:thoughtbook/src/features/authentication/application/auth_exceptions.dart';
import 'package:thoughtbook/src/features/authentication/application/auth_provider.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';

void main() {
  group(
    'Mock Authentication',
    () {
      final provider = MockAuthProvider();

      test(
        'Should not be initialized',
        () {
          expect(provider.isInitialized, false);
        },
      );

      test(
        'Cannot logout if not initialized',
        () {
          expect(
            provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()),
          );
        },
      );

      test(
        'Should be able to initialize',
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
      );

      test(
        'User should be null after initialization',
        () {
          expect(provider.currentUser, null);
        },
      );

      test(
        'Should be able to initialize in less than 2 seconds',
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );

      test(
        'Create user should delegate to logIn function',
        () async {
          final badEmailUser = provider.createUser(
            email: 'foo@bar.com',
            password: 'doNotTouchThis',
          );
          expect(
            badEmailUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>()),
          );

          final badPasswordUser = provider.createUser(
            email: 'thisIsFine@dev.work',
            password: 'foobar',
          );
          expect(
            badPasswordUser,
            throwsA(const TypeMatcher<WrongPasswordAuthException>()),
          );

          final user = await provider.createUser(
            email: 'foo',
            password: 'bar',
          );
          expect(provider.currentUser, user);
          expect(user.isEmailVerified, false);
        },
      );

      test(
        'Logged user should be able to get verified',
        () {
          provider.sendEmailVerification();
          final user = provider.currentUser;
          expect(user, isNotNull);
          expect(user!.isEmailVerified, true);
        },
      );

      test(
        'Should be able to logout and login again',
        () async {
          await provider.logOut();
          await provider.logIn(
            email: 'email',
            password: 'password',
          );
          final user = provider.currentUser;
          expect(user, isNotNull);
        },
      );
    },
  );
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;

  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: 'my_id',
      isEmailVerified: false,
      email: 'foo@bar.com',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      id: 'my_id',
      isEmailVerified: true,
      email: 'foo@bar.com',
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (!isInitialized) throw NotInitializedException();
    if (toEmail == 'invalidEmail') throw InvalidEmailAuthException();
    if (toEmail == 'foo@bar.com') throw UserNotFoundAuthException();

    await Future.delayed(
      const Duration(seconds: 1),
    );
  }
}

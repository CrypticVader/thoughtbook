import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;

  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });
}

class AuthInitial extends AuthState {
  const AuthInitial({required super.isLoading});
}

class AuthRegistering extends AuthState {
  final Exception? exception;

  const AuthRegistering({
    required super.isLoading,
    required this.exception,
  });
}

class AuthForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required super.isLoading,
  });
}

class AuthLoggedIn extends AuthState {
  final AuthUser? user;
  final bool isUserGuest;

  const AuthLoggedIn({
    required this.isUserGuest,
    required this.user,
    required super.isLoading,
  });
}

class AuthNeedsVerification extends AuthState {
  const AuthNeedsVerification({required super.isLoading});
}

class AuthLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;

  const AuthLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText = null,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

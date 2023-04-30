import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';
import 'package:thoughtbook/services/auth/auth_exceptions.dart';
import 'package:thoughtbook/services/auth/bloc/auth_bloc.dart';
import 'package:thoughtbook/services/auth/bloc/auth_event.dart';
import 'package:thoughtbook/services/auth/bloc/auth_state.dart';
import 'package:thoughtbook/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is EmptyCredentialsAuthException) {
            await showErrorDialog(
              context,
              context.loc.error_empty_credentials,
            );
          } else if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_cannot_find_user,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_wrong_credentials,
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_invalid_email,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.auth_error_generic,
            );
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
          child: Column(
            children: [
              const Spacer(
                flex: 1,
              ),
              Text(
                context.loc.welcome_to,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: context.theme.colorScheme.onBackground,
                ),
              ),
              Text(
                context.loc.app_title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Text(
                context.loc.login_view_prompt,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 12,
              ),
              Card(
                elevation: 0,
                color:
                    context.theme.colorScheme.primaryContainer.withOpacity(0.4),
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(128),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _email,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              width: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide.none,
                          ),
                          fillColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          filled: true,
                          prefixIconColor:
                              Theme.of(context).colorScheme.primary,
                          prefixIcon: const Icon(
                            Icons.email_rounded,
                          ),
                          hintText: context.loc.email_text_field_placeholder,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextField(
                        controller: _password,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              width: 2,
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: context.theme.colorScheme.primaryContainer,
                          filled: true,
                          prefixIconColor: context.theme.colorScheme.primary,
                          prefixIcon: const Icon(
                            Icons.password_rounded,
                          ),
                          hintText: context.loc.password_text_field_placeholder,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(
                        AuthEventLogIn(
                          email,
                          password,
                        ),
                      );
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  foregroundColor: context.theme.colorScheme.onPrimary,
                  backgroundColor: context.theme.colorScheme.primary,
                ),
                child: Text(
                  context.loc.login,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      context.theme.colorScheme.surface.withOpacity(0.6),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventForgotPassword());
                },
                child: Text(context.loc.login_view_forgot_password),
              ),
              const Spacer(
                flex: 1,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      context.theme.colorScheme.surface.withOpacity(0.6),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: Text(context.loc.login_view_not_registered_yet),
              )
            ],
          ),
        ),
      ),
    );
  }
}

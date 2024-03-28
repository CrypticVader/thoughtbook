import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_state.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_exceptions.dart';
import 'package:thoughtbook/src/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
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
    final systemInsets = MediaQuery.of(context).padding;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthLoggedOut) {
          if (state.exception is EmptyCredentialsAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.error_empty_credentials,
              showTitle: false,
            );
          } else if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.login_error_cannot_find_user,
              showTitle: false,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.login_error_wrong_credentials,
              showTitle: false,
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.register_error_invalid_email,
              showTitle: false,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.auth_error_generic,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Color.alphaBlend(
          context.theme.colorScheme.inversePrimary.withAlpha(40),
          context.theme.colorScheme.surface,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, systemInsets.top, 16, systemInsets.bottom + 8),
            child: KeyboardVisibilityBuilder(
              builder: (BuildContext context, bool isKeyboardVisible) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 250),
                          height: isKeyboardVisible
                              ? MediaQuery.of(context).size.height * 0.05
                              : MediaQuery.of(context).size.height * 0.1,
                        ),
                        AnimatedSize(
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 250),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: isKeyboardVisible
                                ? [const SizedBox(height: 0)]
                                : [
                                    Text(
                                      context.loc.welcome_to,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                        color: context.theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      context.loc.app_title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                        color: context.theme.colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                                  ],
                          ),
                        ),
                        Text(
                          context.loc.login_view_prompt,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _email,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: context.theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    color:
                                    context.theme.colorScheme.onPrimaryContainer.withAlpha(200),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  contentPadding: const EdgeInsets.all(20),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28.0),
                                    borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(28),
                                      topRight: Radius.circular(28),
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  fillColor:
                                      Theme.of(context).colorScheme.primaryContainer.withAlpha(200),
                                  filled: true,
                                  prefixIconColor: Theme.of(context).colorScheme.primary,
                                  prefixIcon: const Icon(
                                    Icons.email_rounded,
                                  ),
                                  hintText: context.loc.email_text_field_placeholder,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _password,
                                onSubmitted: (_) {
                                  final email = _email.text;
                                  final password = _password.text;
                                  context.read<AuthBloc>().add(
                                        AuthLogInEvent(
                                          email,
                                          password,
                                        ),
                                      );
                                },
                                textInputAction: TextInputAction.go,
                                obscureText: true,
                                autocorrect: false,
                                enableSuggestions: false,
                                style: TextStyle(
                                  color: context.theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    color:
                                    context.theme.colorScheme.onPrimaryContainer.withAlpha(200),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  contentPadding: const EdgeInsets.all(20),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      width: 0.5,
                                      color: context.theme.colorScheme.primary,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(28),
                                      bottomRight: Radius.circular(28),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  fillColor:
                                  context.theme.colorScheme.primaryContainer.withAlpha(200),
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
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: context.theme.colorScheme.surface.withOpacity(0.5),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          ),
                          onPressed: () =>
                              context.read<AuthBloc>().add(const AuthForgotPasswordEvent()),
                          icon: const Icon(Icons.lightbulb_outline_rounded),
                          label: Text(context.loc.login_view_forgot_password),
                        ),
                        const SizedBox(height: 16.0),
                        FilledButton.icon(
                          onPressed: () {
                            final email = _email.text;
                            final password = _password.text;
                            context.read<AuthBloc>().add(AuthLogInEvent(email, password));
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                          ),
                          label: Text(
                            context.loc.login,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: const Icon(Icons.login_rounded),
                        ),
                        AnimatedContainer(
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 250),
                          height:
                          isKeyboardVisible ? 32 : MediaQuery.of(context).size.height * 0.15,
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.read<AuthBloc>().add(const AuthShouldRegisterEvent()),
                          label: Text(context.loc.login_view_not_registered_yet),
                          icon: const Icon(Icons.app_registration_rounded),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: context.theme.colorScheme.surface.withOpacity(0.5),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: isKeyboardVisible
                                ? [const SizedBox(height: 0)]
                                : [
                                    Divider(
                                      height: 32,
                                      thickness: 1.5,
                                      color: context.theme.colorScheme.secondary.withAlpha(100),
                                    ),
                                    FilledButton.tonalIcon(
                                      onPressed: () => context
                                          .read<AuthBloc>()
                                          .add(const AuthLoginAsGuestEvent()),
                                      label: const Text('Continue without an account'),
                                      icon: const Icon(Icons.no_accounts_rounded),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

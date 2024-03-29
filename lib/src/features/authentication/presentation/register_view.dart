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

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with TickerProviderStateMixin {
  bool _passwordMatches = true;

  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _passwordReEntered;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _passwordReEntered = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordReEntered.dispose();
    super.dispose();
  }

  bool _isPasswordMatching() {
    if (_password.text == _passwordReEntered.text) {
      return true;
    } else {
      return false;
    }
  }

  void _passwordFieldListener() {
    setState(() {
      _passwordMatches = _isPasswordMatching();
    });
  }

  void _setupPasswordListener() {
    _password.removeListener(_passwordFieldListener);
    _password.addListener(_passwordFieldListener);

    _passwordReEntered.removeListener(_passwordFieldListener);
    _passwordReEntered.addListener(_passwordFieldListener);
  }

  @override
  Widget build(BuildContext context) {
    _setupPasswordListener();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthRegistering) {
          if (state.exception is EmptyCredentialsAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.error_empty_credentials,
              showTitle: false,
            );
          } else if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.register_error_weak_password,
              showTitle: false,
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.register_error_email_already_in_use,
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
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
            child: KeyboardVisibilityBuilder(
              builder: (BuildContext context, bool isKeyboardVisible) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 250),
                          height: isKeyboardVisible
                              ? MediaQuery.of(context).size.height * 0.05
                              : MediaQuery.of(context).size.height * 0.1,
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease,
                          child: Column(
                            children: isKeyboardVisible
                                ? [
                                    const SizedBox(
                                      height: 0,
                                    ),
                                  ]
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
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.1,
                                    ),
                                  ],
                          ),
                        ),
                        Text(
                          context.loc.register_view_prompt,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _email,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.emailAddress,
                                autofocus: true,
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
                                      topLeft: Radius.circular(28),
                                      topRight: Radius.circular(28),
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  fillColor:
                                      context.theme.colorScheme.primaryContainer.withAlpha(200),
                                  filled: true,
                                  prefixIconColor: context.theme.colorScheme.primary,
                                  prefixIcon: const Icon(
                                    Icons.email_rounded,
                                  ),
                                  hintText: context.loc.email_text_field_placeholder,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              TextField(
                                controller: _password,
                                textInputAction: TextInputAction.next,
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
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  fillColor:
                                      context.theme.colorScheme.primaryContainer.withAlpha(200),
                                  filled: true,
                                  hintText: context.loc.password_text_field_placeholder,
                                  prefixIconColor: context.theme.colorScheme.primary,
                                  prefixIcon: const Icon(
                                    Icons.password_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              TextField(
                                controller: _passwordReEntered,
                                onSubmitted: (_) async {
                                  final email = _email.text;
                                  final password = _password.text;
                                  if (_isPasswordMatching()) {
                                    context.read<AuthBloc>().add(
                                          AuthRegisterEvent(
                                            email,
                                            password,
                                          ),
                                        );
                                  } else {
                                    await showErrorDialog(
                                      context: context,
                                      text: context.loc.register_error_passwords_do_not_match,
                                      showTitle: false,
                                    );
                                  }
                                },
                                obscureText: true,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.go,
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
                                  filled: true,
                                  fillColor: _passwordMatches
                                      ? context.theme.colorScheme.primaryContainer.withAlpha(200)
                                      : context.theme.colorScheme.errorContainer.withAlpha(200),
                                  errorText: _passwordMatches
                                      ? null
                                      : context.loc.register_error_passwords_do_not_match,
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
                                  errorBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(28),
                                      bottomRight: Radius.circular(28),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      width: 0.5,
                                      color: context.theme.colorScheme.error,
                                    ),
                                  ),
                                  hintText: context.loc.reenter_password_text_field_placeholder,
                                  prefixIconColor: _passwordMatches
                                      ? context.theme.colorScheme.primary
                                      : context.theme.colorScheme.error,
                                  prefixIcon: const Icon(
                                    Icons.password_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            if (_isPasswordMatching()) {
                              context.read<AuthBloc>().add(
                                    AuthRegisterEvent(
                                      email,
                                      password,
                                    ),
                                  );
                            } else {
                              await showErrorDialog(
                                context: context,
                                text: context.loc.register_error_passwords_do_not_match,
                                showTitle: false,
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                          ),
                          label: Text(
                            context.loc.register,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: const Icon(Icons.app_registration_rounded),
                        ),
                        AnimatedContainer(
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 250),
                          height: isKeyboardVisible
                              ? MediaQuery.of(context).size.height * 0.01
                              : MediaQuery.of(context).size.height * 0.25,
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: context.theme.colorScheme.surface.withOpacity(0.5),
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(const AuthLogOutEvent());
                          },
                          label: Text(
                            context.loc.register_view_already_registered,
                          ),
                          icon: const Icon(Icons.switch_account_rounded),
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
